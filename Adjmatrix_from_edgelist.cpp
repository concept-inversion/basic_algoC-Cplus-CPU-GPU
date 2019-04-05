#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include<math.h>
using namespace std;

void displays(int *data,int len)
{
    int total= len*len;
    for(int i=0;i<total;i++)
    {
        if(i%5==0){cout<<"\n";}
        cout<<data[i]<<"\t";
    }
}

void adj_calc(int *n1,int *n2, int *adj_matrix ,int edgelist_len,float *degree_data,int n_nodes,int *I )
{
    int total = n_nodes*n_nodes;
    cout<<"total:"<<total<<"\t Edgelist_len:"<<edgelist_len<<"\n";
    for(int i=0;i<total;i++)
    {
        adj_matrix[i]=0;
        degree_data[i]=0;
        if(i%(n_nodes+1)==0){I[i]=1;}
        else I[i]=0;
    }
    
    for(int j=0;j<edgelist_len;j++)
    {
        printf("\n");
        int index1= (n1[j]-1)*(n_nodes)+ n2[j]-1;
        int index2= (n2[j]-1)*(n_nodes)+ n1[j]-1; 
        printf("n1:%d,n2:%d,index1:%d,index2:%d\n",n1[j],n2[j],index1,index2);
        adj_matrix[index1]=1;
        adj_matrix[index2]=1;
    }
    cout<<"Adj Matix\n";
    displays(adj_matrix,n_nodes);
    cout<<"I\n";    
    displays(I,n_nodes);
    cout<<"\n";    

    // Calculate degree
    for(int i=0; i<n_nodes;i++)
    {
        int sum=0;
        for(int k=0;k<n_nodes;k++)
        {
            sum+=adj_matrix[i*(n_nodes)+k];
        }
        cout<<"Sum for row:"<<i<<"is"<<sum<<"\n";
        float temp= 1/sqrt(sum);
        degree_data[i*n_nodes+i]=temp;
    }
    //displays(degree_data,n_nodes);
    //calculate Ahat
    for (int i=0;i<total;i++)
    {
        adj_matrix[i]=adj_matrix[i]+I[i];
    }
    cout<<"Ahat\n";
    displays(adj_matrix,n_nodes);
    cout<<"\n";  
    
}

int main(int args, char **argv)
{
    int edgelist_len = 4;
    int n_nodes=5;
    int total_nodes=n_nodes*n_nodes;
    int n1[] = {1,1,2,5};
    int n2[] = {2,4,3,1};
    int *data = (int *) malloc(sizeof(int)*total_nodes);
    int *I = (int *) malloc(sizeof(int)*total_nodes);
    float *degree_data = (float *) malloc(sizeof(float)*total_nodes);
    for(int i=0;i<total_nodes;i++)
    {
        data[i]=0;
    }
    adj_calc(n1,n2,data,edgelist_len,degree_data,n_nodes,I);
}
