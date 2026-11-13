#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include "qoi_baseline.h"
void *qoi_encode_ref(const void*, const qoi_desc*, int*);
void *qoi_encode_opt(const void*, const qoi_desc*, int*);
static uint64_t ns(void){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return t.tv_sec*1000000000ull+t.tv_nsec;}
static uint32_t st=7; static uint32_t rnd(void){st=st*1664525u+1013904223u;return st;}
int main(void){
  int W=4000,H=2500,ch=4;
  size_t n=(size_t)W*H*ch;
  unsigned char*px=malloc(n);
  for(size_t i=0;i<n;i++){
    int x=(i/ch)%W,y=(i/ch)/W,mode=(x/64+y/64)&3;
    if(i%ch==3){px[i]=(y%17==0)?(rnd()&255):255;continue;}
    px[i]= mode==0?(unsigned char)(x*3+y):mode==1?40:mode==2?(unsigned char)(rnd()&255):(unsigned char)rnd();
  }
  qoi_desc d={W,H,ch,QOI_SRGB};
  int lr,lo; unsigned char*br=qoi_encode_ref(px,&d,&lr),*bo=qoi_encode_opt(px,&d,&lo);
  if(lr!=lo||memcmp(br,bo,lr)){printf("MISMATCH\n");return 1;}
  printf("byte-identical, %d bytes (%.1f KB)\n",lo,lo/1024.0);
  int R=40;
  double tr[64],to[64];
  for(int r=0;r<R;r++){
    uint64_t a=ns(); volatile int z=lr; (void)z; unsigned char*b=qoi_encode_ref(px,&d,&lr); uint64_t c=ns();
    tr[r]=(c-a)/1e6; free(b);
    a=ns(); b=qoi_encode_opt(px,&d,&lo); c=ns(); to[r]=(c-a)/1e6; free(b);
  }
  /* simple median+min */
  for(int i=0;i<R;i++)for(int j=i+1;j<R;j++){
    if(tr[i]>tr[j]){double t=tr[i];tr[i]=tr[j];tr[j]=t;}
    if(to[i]>to[j]){double t=to[i];to[i]=to[j];to[j]=t;}
  }
  printf("10MP RGBA  ref: med %.2f ms min %.2f ms | opt: med %.2f ms min %.2f ms | med speedup %.2fx min speedup %.2fx\n",
    tr[R/2],tr[0],to[R/2],to[0],tr[R/2]/to[R/2],tr[0]/to[0]);
  free(px);free(br);free(bo);
  return 0;
}
