#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "qoi_baseline.h"
void *qoi_encode_ref(const void*, const qoi_desc*, int*);
void *qoi_encode_opt(const void*, const qoi_desc*, int*);
static unsigned int s=1;
static unsigned int rnd(void){s=s*1664525u+1013904223u;return s;}
int main(void){
  int fails=0;
  /* adversarial: mostly noise to force RGB/RGBA, plus alpha flips */
  for(int t=0;t<20000;t++){
    int w=1+(rnd()%40), h=1+(rnd()%40), ch=(rnd()&1)?4:3;
    size_t n=(size_t)w*h*ch;
    unsigned char *px=malloc(n);
    int style=rnd()%4;
    for(size_t i=0;i<n;i++){
      unsigned char v;
      if(style==0) v=(rnd()&1)?0:255;
      else if(style==1) v=(unsigned char)rnd();
      else if(style==2) v=(unsigned char)(i*37+11);
      else v=(i%ch==3)?(unsigned char)(rnd()&1?0:255):128;
      px[i]=v;
    }
    qoi_desc d={w,h,(unsigned char)ch,QOI_SRGB};
    int lr,lo;
    unsigned char *r=qoi_encode_ref(px,&d,&lr);
    unsigned char *o=qoi_encode_opt(px,&d,&lo);
    if(lr!=lo || memcmp(r,o,lr)!=0){
      printf("DIFF t=%d %dx%dc%d style%d lens %d/%d\n",t,w,h,ch,style,lr,lo);
      for(int k=0;k<lr&&k<lo;k++) if(r[k]!=o[k]){printf(" first byte %d: %02x vs %02x\n",k,r[k],o[k]);break;}
      fails++; if(fails>5) break;
    }
    free(r);free(o);free(px);
  }
  printf(fails?"FUZZ FAIL %d\n":"fuzz: 20000 adversarial images all byte-identical\n",fails);
  return fails?1:0;
}
