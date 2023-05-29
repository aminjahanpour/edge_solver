 #include <stdio.h>
 #include <math.h>

float cost_function(float x[2], int dim) {

    /*
    return 10 * len(x) + sum(x ** 2 - 10 * np.cos(2 * np.pi * x))
    */

    float d = 2.0;

    float ret = 10.0F * dim;


    for (int i = 0; i < dim; i++)
    {
        ret = ret + sqrtf(x[i]);
        // ret = ret + x[i] * x[i] - 10.0F * cosf(2.0F * 3.1415F * x[i]);
    }
    

    // float ret = (x[0] + 1.0F) * (x[1] + 1.0F) + 3.1415F;
    // float ret = sinf(x[0]) + cosf(x[1]);


    // printf("x[0] = %f , f = %f\n", x[0], f);

    return ret;

}






float main_function()
{

    int size = 10;


    int dim = 2;


    float lb = 0.0F;
    float ub = 10.0F;
    float step = 0.95F;

    float x[dim];

    float best_x = 0.0F;
    float best_f = 10000.0F;


    float j = lb;

    
    int budget = 20;

    int i = 0;


    // --------> reset the solver (rst)
    // provide:
    // - dim
    // - budget



    while (i < budget)
    {
        
        // -------->  read new solutions (ask)
        // every solution has 16 dv
        // each dv is stored in 2 bytes
        j = j + step;

        x[0] = j;
        x[1] = j;




        // calculate cost-function
        float f = cost_function(x, dim);


        // -------->  tell the solver about the new cost function (tell)



        // keep track of the best found
        if(f < best_f) {
            best_f = f;
            best_x = x[0];
        }


        i = i + 1;

    }
    



    // printf("best_x = %f\n, best_f = %f\n", best_x, best_f);

    
    return best_f;
}


int main()
{

    float ret = main_function();

    return 0;
}















