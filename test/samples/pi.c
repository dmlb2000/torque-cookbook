#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <mpi.h>

int main(int argc, char ** argv)
{
    if( MPI_Init(&argc, &argv) != MPI_SUCCESS )
    {
        fprintf(stderr, "MPI_Init Failed!!!\n");
        return -1;
    }

    int world_rank = -1;
    long int le_one = 0;
    long int g_one = 0;
    long int sum_le_one = 0;
    long int sum_g_one = 0;

    if( MPI_Comm_rank(MPI_COMM_WORLD, &world_rank) != MPI_SUCCESS )
    {
        fprintf(stderr, "MPI_Comm_rank Failed!!!\n");
        return -1;
    }

    if (argc <= 1)
    {
        fprintf(stderr, "wrong usage we need an integer\n%s TIMES\n", argv[0]);
        return -1;
    }

    char *endchk = NULL;
    long int times = strtol(argv[1], &endchk, 0);
    /* check the end pointer to see if the argument is valid */
    long int cur = 0;
    int a,b;
    double a_p, b_p;
    long int *le_one_sums;
    long int *g_one_sums;
    le_one_sums = calloc(omp_get_num_threads(), sizeof(long int));
    g_one_sums = calloc(omp_get_num_threads(), sizeof(long int));
    fprintf(stderr, "OMP_NUM_THREADS=%d\n", omp_get_num_threads());
    #pragma omp parallel for private(a,b,a_p,b_p)
    for(cur = 0; cur < times ; cur++)
    {
        a = rand();
        b = rand();
        a_p = (double) a / (double) RAND_MAX;
        b_p = (double) b / (double) RAND_MAX;
        if( (a_p * a_p) + (b_p * b_p) <= 1.0 )
            le_one_sums[omp_get_thread_num()]++;
        else
            g_one_sums[omp_get_thread_num()]++;
    }
    for(cur = 0; cur < omp_get_num_threads(); cur++)
    {
        le_one += le_one_sums[cur];
        g_one += g_one_sums[cur];
    }

    if( MPI_Reduce(&g_one, &sum_g_one, 1, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD) != MPI_SUCCESS )
    {
        fprintf(stderr, "MPI_Reduce Failed!!!\n");
        return -1;
    }
    if( MPI_Reduce(&le_one, &sum_le_one, 1, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD) != MPI_SUCCESS )
    {
        fprintf(stderr, "MPI_Reduce Failed!!!\n");
        return -1;
    }

    printf("(%d) g_one - %d\n", world_rank, g_one);
    printf("(%d) le_one - %d\n", world_rank, le_one);
    if( world_rank == 0 )
    {
        printf("(%d) sum_le_one - %d\n", world_rank, sum_le_one);
        printf("(%d) sum_g_one - %d\n", world_rank, sum_g_one);
        printf("(%d) PI - %lf\n", (double)sum_le_one*4.0/((double)sum_g_one + (double)sum_le_one));
    }

    if( MPI_Finalize() != MPI_SUCCESS )
    {
        fprintf(stderr, "MPI_Finalize Failed!!!\n");
        return -1;
    }
    return 0;
}
