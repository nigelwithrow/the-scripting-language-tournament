#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <zlib.h>
#include <pthread.h>

#define MAX_LENGTH 256

void *scan(void *ptr) {
   gzFile file = (gzFile)ptr;
   struct tar {
     char name[100];   char _unused[24];
     char size[12];    char _padding[376];
   } tar;

   while (gzread(file, &tar, sizeof(tar)) == sizeof(tar)) {
      if (tar.name[0] == '\0') break; // EOF marker
      // printf("Scanning '%s'\n", tar.name);

      int size;
      sscanf(tar.size, "%o", &size);
      size = (size + 511) / 512 * 512;

      const int namelen = strlen(tar.name);
      if (namelen >= 7 && strcmp(tar.name + namelen - 7, ".tar.gz") == 0) {
         // Archive
         int p[2];
         if (pipe(p) != 0) exit(-1);

         pthread_t thread;
         pthread_create(&thread, NULL, scan, gzdopen(p[0], "r"));

         while (size > 0) {
            char buff[512];
            if (gzread(file, buff, sizeof(buff)) != sizeof(buff)) exit(-1);
            if (write(p[1], buff, sizeof(buff)) != sizeof(buff)) exit(-1);
            size -= sizeof(buff);
         }
         close(p[1]);

         pthread_join(thread, NULL);
         close(p[0]);
      } else {
         // Text file
         const int next_pos = gztell(file) + size;

         char line[MAX_LENGTH];
         while (true) {
            const int pos = gztell(file);
            if (pos >= next_pos) break;
            size = next_pos - pos;

            if (!gzgets(file, line, size < MAX_LENGTH ? size : MAX_LENGTH)) break;
            if (line[0] == '\0') break;
            if (strncmp(line, "Answer: ", strlen("Answer: ")) == 0) {
               puts(line);
               exit(0);
            }
         }

         gzseek(file, next_pos, SEEK_SET);
      }
   }
   gzclose(file);
   return NULL;
}

int main (int argc, char *argv[]) {
   scan(gzopen(argv[1], "r"));
   puts("Not found!");
   return 0;
}
