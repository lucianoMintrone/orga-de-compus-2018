#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int minus(char *a, char *b, int num) {
  if (num == 0) {
    return atoi(a) - atoi(b);
  } else {
    return strcmp(a, b);
  }
}

void c_qsort(char** izq, char** der, int num) {
  char **i, **j, **pivot = NULL;
  char * temp = NULL;

  if(izq < der){
    pivot=izq;
    i=izq;
    j=der;

    while(i < j){
      while(minus(*i, *pivot, num) <= 0 && i < der)
        i++;
      while(minus(*j, *pivot, num) > 0)
        j--;
      if(i<j){
        temp=*i;
        *i=*j;
        *j=temp;
      }
    }

    temp=*pivot;
    *pivot=*j;
    *j=temp;

    c_qsort(izq,j-1, num);
    c_qsort(j+1,der, num);
  }
}
