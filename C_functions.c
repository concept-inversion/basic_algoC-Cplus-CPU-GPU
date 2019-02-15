void display(int length,int *a)
{

    std::cout<<"\n size:"<<length<<"\n";
    for(int i=0;i<length;i++)
    {
        std::cout<<a[i]<<"\n";
    }
    std::cout<<"\n";
}


void prefix_sum(int length,int *arr)
{
    
    int prefix_sum[length];
    prefix_sum[0]=arr[0];
    for (int i=1;i<length;i++)
    {
        prefix_sum[i]= prefix_sum[i-1]+ arr[i];
    }


int binary_search(int value, int *arr)
{
    int length = sizeof(arr)/sizeof(int);
    int low=0;
    int high=length-1;
    int index=0;
    while (low<high)
    {
        index = (low+high)/2;
        if (value<arr[index])
        {
            //set high to index-1
            high= index-1;
        }
        else if (value>arr[index])
        {
            // set low to index+1
            low = low+1;
        }
        else
        {
            break;
        } 
    return index;
    }

}
