/* Headders including */
#include <stdio.h>
#include <stdlib.h>

/* Main function */
int main(int argc, char *argv[]) {
  // Variables define
  FILE *fp;
  int i;
  int color[3];
  char wdata[3];

  // Argument check
  if(argc == 1) {
    fprintf(stderr, "No argument");
    exit(EXIT_FAILURE);
  } else if(argc < 4) {
    fprintf(stderr, "Too few argument");
    exit(EXIT_FAILURE);
  } else if(argc > 4) {
    fprintf(stderr, "Too match argument");
    exit(EXIT_FAILURE);
  }

  // Write data make
  for(i = 0; i < 3; i++) {
    color[i] = atoi(argv[i + 1]);
    if(color[i] < 0) {
      wdata[2 - i] = 0;
    } else if(0xFF < color[i]) {
      wdata[2 - i] = 0xFF;
    } else {
      wdata[2 - i] = color[i];
    }
  }

  // File open
  fp = fopen("color.bmp", "ab");
  if(fp == NULL) {
    fprintf(stderr, "Failed to open a bin file.");
    exit(EXIT_FAILURE);
  }

  // Binary write
  for(i = 0; i < 10000; i++) {
    fwrite(wdata, 1, 3, fp);
  }

  // Quit
  fclose(fp);
  return 0;
}
