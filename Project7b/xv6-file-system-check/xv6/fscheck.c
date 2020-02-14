#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>


#define stat xv6_stat
#include "types.h"
#include "fs.h"
#include "stat.h"
#undef stat

#define bMap1 "ERROR: bitmap marks data free but data block used by inode.\n"
#define bMap2 "ERROR: bitmap marks block in use but it is not in use.\n"
int fd, fsfd;

struct superblock sb;

void
rsect(uint sec, void *buf) {
  if (lseek(fd, sec * BSIZE, 0) != sec * BSIZE) {
      printf("lseek");
      exit(1);
  }
  if (read(fd, buf, BSIZE) != BSIZE) {
      printf("read");
      exit(1);
  }
}

int traverse_dir_by_inum(uint addr, ushort inum) {
  if (lseek(fd, addr*BSIZE, SEEK_SET) != addr*BSIZE) {
         perror("lseek");
         exit(1);
    }
  struct dirent buf;
  int i;
  for (i = 0; i < IPB; i++) {
    read(fd, &buf, sizeof(struct dirent));
    if (buf.inum == inum) {
      return 0;
    }
  }
  return 1;
}

int error2check(struct dinode currentInode) {
  int count = 0;
  for (int i = 0; i < NDIRECT; i++) {
    if (currentInode.addrs[i] != 0) {
      count++;
    }
  }
  if (currentInode.addrs[NDIRECT] != 0) {
    if (lseek(fd, currentInode.addrs[NDIRECT] * BSIZE,
       SEEK_SET) != currentInode.addrs[NDIRECT] * BSIZE) {
      perror("lseek");
      exit(1);
    }
    uint buf;
    for (int x = 0; x < NINDIRECT; x++) {
      if (read(fd, &buf, sizeof(uint)) != sizeof(uint)) {
        perror("read");
        exit(1);
      }
      if (buf != 0) {
        count++;
      }
    }
  }
  if (currentInode.size == 0) {
      if (count == 0) {
          return 0;
      } else {
          return 1;
      }
  }
  int leastSize = (count-1) * 512;
  int maxSize = (count) * 512;
  if (currentInode.size > leastSize && currentInode.size <= maxSize) {
    return 0;
  }
  return 1;
}

int findDirectoryByName(uint address, char *name, int compareAgainst) {
    struct dirent buf;
    lseek(fsfd, address*BSIZE, SEEK_SET);
    for (int i = 0; i < BSIZE / sizeof(struct dirent) ; i++) {
          read(fsfd, &buf, sizeof(struct dirent));
          if (buf.inum == 0) {
              continue;
          }
          if (strcmp(name, buf.name) == 0) {
              int a = (int) buf.inum;
              if (a != compareAgainst) {
                 return 0;
              }
          }
    }
    return 1;
}

int error4check(struct dinode currentInode, int inodeNum) {
    for (int i = 0; i < NDIRECT; i++) {
      if (currentInode.addrs[i] == 0) {
         continue;
      }
      if (findDirectoryByName(currentInode.addrs[i], ".", inodeNum)) {
         return 0;
      }
    }
    return 1;
}

int error6check(uint* addresses) {
  int start = sb.bmapstart*BSIZE + sb.size/8 - sb.nblocks/8;
  uint bit;
  int count = (sb.bmapstart + 1);

  if (lseek(fd, start, SEEK_SET) != start) {
    perror("lseek");
    return 1;
  }

  int i;
  int byte;
  for (i = count; i < sb.size; i+=8) {
    read(fsfd, &byte, 1);
    int x;
    for (x = 0; x < 8; x++ , count++) {
      bit = (byte >> x)%2;
      if (bit != 0) {
        if (addresses[count] == 0) {
          return 1;
        }
      }
    }
  }
  return 0;
}

int check_inum_indir(uint addr, ushort inum) {
    lseek(fsfd, addr*BSIZE, SEEK_SET);
    struct dirent buf;
    for (int i = 0; i < BSIZE / sizeof(struct dirent); i++) {
        read(fd, &buf, sizeof(struct dirent));
        if (buf.inum == inum) {
            return 0;
        }
    }
    return 1;
}

int inode_check_directory(uint target_inum) {
    struct dinode compare_inode;
    for (int compare_inum = 0; compare_inum < sb.ninodes; compare_inum++) {
        lseek(fd, sb.inodestart*BSIZE +
        compare_inum * sizeof(struct dinode), SEEK_SET);
        read(fd, &compare_inode, sizeof(struct dinode));
        if (compare_inode.type != 1) {continue;}
        for (int d_ptr = 0; d_ptr < NDIRECT; d_ptr++) {
            if (compare_inode.addrs[d_ptr] == 0) {
                  continue;
            } else if (check_inum_indir(compare_inode.addrs[d_ptr],
              target_inum) == 0) {
                  return 0;
            }
        }
        uint ind_DIR_address;
        for (int ind_ptr = 0; ind_ptr < NINDIRECT; ind_ptr++) {
            lseek(fd, compare_inode.addrs[NDIRECT] *
            BSIZE + ind_ptr*sizeof(uint), SEEK_SET);
            read(fd, &ind_DIR_address, sizeof(uint));
            if (check_inum_indir(ind_DIR_address, target_inum) == 0) {
                 return 0;
            }
        }
    }
    fprintf(stderr, "ERROR: inode marked use but not found in a directory.\n");
    return 1;
}

int check_block_inuse(uint* address) {
    int db_inbmap = sb.bmapstart*BSIZE + sb.size/8 - sb.nblocks/8;
    int current_block = (sb.bmapstart + 1);
    lseek(fsfd, db_inbmap, SEEK_SET);
    uint bit_to_check;
    int byte_to_check;
    for (int i = current_block; i < sb.size; i += 8) {
        read(fsfd, &byte_to_check, 1);
        for (int x = 0; x < 8; x++) {
            bit_to_check = (byte_to_check >> x)%2;
            if (bit_to_check != 0) {
                if (address[current_block] == 0) {
                    fprintf(stderr, bMap2);
                    return 1;
                }
            }
            current_block++;
        }
    }
    return 0;
}

int check_inode_addr(struct dinode current_inode) {
        uint addr, byte;
        for (int i = 0; i < NDIRECT + 1; i++) {
            if (current_inode.addrs[i] == 0) {
                continue;
            }
            lseek(fd, sb.bmapstart*BSIZE +
                current_inode.addrs[i]/8, SEEK_SET);
            read(fd, &byte, 1);
            byte = byte >> current_inode.addrs[i]%8;
            byte = byte%2;
            if (byte == 0) {
                fprintf(stderr, "%s", bMap1);
                return 1;
            }
        }
        if (current_inode.addrs[NDIRECT] != 0) {
            for (int x = 0; x < NINDIRECT; x++) {
                lseek(fd, current_inode.addrs[NDIRECT]
                * BSIZE + x*sizeof(uint), SEEK_SET);
                if (read(fd, &addr, sizeof(uint)) != sizeof(uint)) {
                    perror("read");
                    exit(1);
                }
                if (addr != 0) {
                    lseek(fd, sb.bmapstart*BSIZE + addr/8, SEEK_SET);
                    read(fd, &byte, 1);
                    byte = byte >> current_inode.addrs[x]%8;
                    byte = byte%2;
                    if (byte == 0) {
                        fprintf(stderr, bMap1);
                        return 1;
                    }
                }
            }
        }
        return 0;
}




int main(int argc , char *argv[]) {
    if (argc < 2) {
        printf("Usage   : fscheck <image>\n");
        exit(1);
    }
    fsfd = open(argv[1], O_RDONLY);
    fd = open(argv[1], O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "ERROR: image not found\n");
        exit(1);
    }
    uchar buf[BSIZE];
    rsect(SUPERBLOCK, buf);
    memmove(&sb, buf, sizeof(sb));

    int inum;
    struct dinode cur_inode;
    int check2 = 0;
    for (inum = 0; inum < ((int) sb.ninodes); inum++) {
        if (lseek(fd, sb.inodestart *
        BSIZE + inum * sizeof(struct dinode),
        SEEK_SET) != sb.inodestart *
        BSIZE + inum * sizeof(struct dinode)) {
            perror("lseek");
            exit(1);
        }
        if (read(fd, buf, sizeof(struct dinode)) != sizeof(struct dinode)) {
            perror("read");
            exit(1);
        }
        memmove(&cur_inode, buf, sizeof(cur_inode));
        if (cur_inode.type < 0 || cur_inode.type > 3) {
            char* msg = "ERROR: bad inode.";
            fprintf(stderr, "%s\n", msg);
            exit(1);
        }
    }
    uint addr[1001];
    for (int i=0; i < sb.size; i++) {
        addr[i] = 0;
    }
    for (int inum = 0; inum < (int) sb.ninodes; inum++) {
        if (lseek(fd, sb.inodestart * BSIZE +
        inum * sizeof(struct dinode), SEEK_SET)
        != sb.inodestart * BSIZE + inum *
        sizeof(struct dinode)) {
            perror("lseek");
            exit(1);
        }
    if (read(fd, buf, sizeof(struct dinode)) != sizeof(struct dinode)) {
         perror("read");
         exit(1);
    }
    memmove(&cur_inode, buf, sizeof(cur_inode));
    if (cur_inode.type != 0) {
      check2 = error2check(cur_inode);
      if (check2 == 1) {
        char* msg = "ERROR: bad size in inode.";
        fprintf(stderr, "%s\n", msg);
        exit(1);
      }
    }
  }
  struct stat fs_stat;
  fstat(fsfd, &fs_stat);
  void* fs_ptr = mmap(NULL, fs_stat.st_size, PROT_READ, MAP_PRIVATE, fsfd, 0);
  struct dinode *curr = (struct dinode*)
  (fs_ptr+ (sb.inodestart *BSIZE) + sizeof(struct dinode));
  if (curr->type != 1) {
    fprintf(stderr, "ERROR: root directory does not exist.\n");
    exit(1);
  }
  struct dirent* dir = fs_ptr + (BSIZE*curr->addrs[0]);
  if (dir->inum == 1) {
         if ((dir+1)->inum != 1) {
           fprintf(stderr, "ERROR: root directory does not exist.\n");
          exit(1);
         }
  }

  for (int i = 0; i < (int) sb.ninodes; i++) {
     if (lseek(fd, sb.inodestart * BSIZE + i *
     sizeof(struct dinode), SEEK_SET) !=
     sb.inodestart * BSIZE + i * sizeof(struct dinode)) {
         perror("lseek");
         exit(1);
     }
     if (read(fd, buf, sizeof(struct dinode)) != sizeof(struct dinode)) {
         perror("read");
         exit(1);
      }
     memmove(&cur_inode, buf, sizeof(cur_inode));
     if (cur_inode.type == 1) {
      int check4 = 0;
      check4 = error4check(cur_inode, i);
      if (check4 == 1) {
        close(fd);
        char* msg = "ERROR: current directory mismatch.";
        fprintf(stderr, "%s\n", msg);
        exit(1);
      }
     }
  }
  for (int current_inum = 0; current_inum
  < ((int) sb.ninodes); current_inum++) {
      lseek(fsfd, sb.inodestart * BSIZE +
      current_inum * sizeof(struct dinode), SEEK_SET);
      if (read(fsfd, buf, sizeof(struct dinode)) != sizeof(struct dinode)) {
           perror("read");
           exit(1);
      }
      memmove(&cur_inode, buf, sizeof(cur_inode));
      if (cur_inode.type != 0) {
          if (check_inode_addr(cur_inode)) {
              exit(1);
          }
      }
  }
  if (check_block_inuse(addr)) {
      exit(1);
  }
  for (int current_inum = 0; current_inum <
  ((int) sb.ninodes); current_inum++) {
        lseek(fsfd, sb.inodestart * BSIZE +
        current_inum * sizeof(struct dinode), SEEK_SET);
        if (read(fsfd, buf, sizeof(struct dinode))
        != sizeof(struct dinode)) {
           perror("read");
           exit(1);
        }
        memmove(&cur_inode, buf, sizeof(cur_inode));

        if (cur_inode.type != 0) {
            if (inode_check_directory(current_inum)) {
            return 1;
            }
        }
    }
  exit(0);
}

