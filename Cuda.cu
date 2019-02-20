/*
Vector addition with a single thread for each addition
*/


__global__ void
 simple_addition(int *a, int *b,int *c,int len)
{
    int tid=threadIdx.x +blockIdx.x*blockDim.x ;
    //while (tid<len)
    c[tid]=a[tid]+b[tid];  
    //printf("I am block: %d with tid: %d Result: %d \n",blockIdx.x,tid,c[tid]);  
    
}

/*
Vector addition with thread mapping and thread accessing its neighbor parallely
*/

//slower than simpler
__global__ void
good_addition(int *a, int *b, int *c, int len)
{
 int tid= threadIdx.x + blockIdx.x * blockDim.x; 
 const int thread_count= blockDim.x*gridDim.x;
 int step = len/thread_count;

 int start_index = tid*step;
 int end_index= (tid+1)* step;
 if (tid==thread_count-1) end_index=len;
 //printf("Step is %d\n",step);
 while(start_index< end_index)
    {
    c[start_index]=a[start_index]+b[start_index];

    //printf("I am block: %d with tid: %d Result %d \n",blockIdx.x,tid,c[tid]);
    start_index +=1;
    }
}


/*
Matrix Matrix multiplication with a single thread for each row
*/

__global__ void
matrix_matrix_mul_old(int *a, int *b, int *c, int n_row, int n_col, int n_comm)

{
    int tid= threadIdx.x + blockIdx.x * blockDim.x;
    int temp=0;
    while(tid<n_row)
    {
        for (int k=0;k<n_col;k++)
        {
           temp=0; 
            for(int j=0;j<n_comm;j++)
            {
                temp+= a[n_comm*tid+j]* b[j*n_col+k];
            }
            c[tid*n_col+k]=temp;
        }    
            tid+=blockDim.x * gridDim.x;
        
    }
}

/*
  Matrix Matrix multiplication with a single thread for each result element
*/
__global__ void
matrix_matrix_new(int *a, int *b, int *c, int n_row, int n_col, int n_comm)
{
    int tid= threadIdx.x + blockIdx.x *  blockDim.x;
    int temp=0;
    while(tid<n_row*n_col)
    {
        // find the row index of A
        int i=tid / n_col;
        // find the column index of B
        int j=tid % n_col;
        // multiply the row and column
        temp=0;
        for(int k=0;k<n_comm;k++)
        {
         temp+= a[i*n_comm+k]*b[j+k*n_col];
        }
        c[tid]=temp;
        tid+= blockDim.x * gridDim.x;
    }
}


/*
  Matrix Vector multiplication with a block with 4 threads per block, shared block mem and parallel reduce
*/

__global__ void
good_multiplication(int*a,int*b,int *c,int n_col=2,int n_row=2)
{

   __shared__ int intermediate[4];
int tid= threadIdx.x + blockIdx.x * blockDim.x;
int index = (blockDim.x* blockIdx.x)+ threadIdx.x;
int length = blockDim.x;
// Each thread needs two value
intermediate[threadIdx.x]=a[index]*b[threadIdx.x];
printf("\n BlockID:%d,  Tid: %d, index: %d, value:%d \n ",blockIdx.x,tid,threadIdx.x,intermediate[threadIdx.x]);
__syncthreads();



// Now add all the item in intermidate value with parallel reduce. Determine the number of steps required for reduction for each block.
int total_steps=log2f(length);
//printf("Number of step is %d",total_steps);
int active=0;

// start a loop 
while((threadIdx.x<=(length/2))){
printf("%d is active. length = %d\n",threadIdx.x,length);
if(threadIdx.x==(length/2))
{
    //check if the sequence is odd
    
    if(length%2==1){
        printf("%d should copy value\n",threadIdx.x);
        intermediate[threadIdx.x]=intermediate[threadIdx.x+length/2];
    }
    
}
else
{
    intermediate[threadIdx.x]+=intermediate[threadIdx.x+length/2];
}
length = length/2+ length%2;
printf("New length is %d\n",length);
__syncthreads();
//printf("Intermediate sum is %d\n",intermediate[threadIdx.x]);



if(length==1 && threadIdx.x==0 )
{
// write to global memory

    c[blockIdx.x]=intermediate[threadIdx.x];
    printf("\n Thread 0 wrote result");
    break;
}
}
}

void display(int *a,int len)
{
    printf("\n");
    for (int i=0;i<len;i++)
    {
        printf("%d \n",a[i]);
    }
}



/*
  Parallel reduce with elements in intermediate array and result in c array.
*/


while((threadIdx.x<=(length/2))){
printf("%d is active. length = %d\n",threadIdx.x,length);
if(threadIdx.x==(length/2))
{
    //check if the sequence is odd
    
    if(length%2==1){
        printf("%d should copy value\n",threadIdx.x);
        intermediate[threadIdx.x]=intermediate[threadIdx.x+length/2];
    }
    
}
else
{
    intermediate[threadIdx.x]+=intermediate[threadIdx.x+length/2];
}
length = length/2+ length%2;
printf("New length is %d\n",length);
__syncthreads();
//printf("Intermediate sum is %d\n",intermediate[threadIdx.x]);



if(length==1 && threadIdx.x==0 )
{
// write to global memory

    c[blockIdx.x]=intermediate[threadIdx.x];
    printf("\n Thread 0 wrote result");
    break;
}
}


/*
Parallel reduce coalesced
*/
__shared__ int a[5];
117         if(threadIdx.x==0){
118         for (int i=0; i<5;i++){
119         a[i]=i;}}
120         int len=5;
121         while(len/2>0 && threadIdx.x<len)
122         {
123         int required = len/2 + len%2;
124         int offset = blockDim.x; 
125         //printf("\nStart:%d, step:%d,stop:%d\n",start,step,stop);
126         int halfpoint=(len/2);
127         printf("Halfpoint:%d\n ",halfpoint);
128                 for (int i =threadIdx.x; i<required;i+=offset)
129                 {
130                 int temp1=a[i];
131                 int temp2=a[i+halfpoint];
132                 __syncthreads();
133                         
134                 if  (i == (required-1) && i>0)
135                 {
136                 if (required%2==1)
137                         {
138                         //printf("\n copy for %d\n",i);
139                         a[i]=temp2;
140                         }
141                 }
142                 else{a[i]= temp1+temp2;}
143                 __syncthreads();
144                 printf("thread: %d working on:%d and %d,value: %d\n",threadIdx.x,i,i+halfpoint,a[i]);
145                 }
146                 __syncthreads();
147                 len=halfpoint+len%2;
148         }
149         printf("Result: %d  thread%d \n", a[0],threadIdx.x);

