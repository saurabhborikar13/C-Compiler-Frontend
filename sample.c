int a, b, c;
float x;

a = 2;
b = 5;
x = 2.5;

while (a < b) {
    if (x > 1.0) {
        if (a != 3)
            c = a + b;
        else
            c = a - b;
    } else {
        c = a * b;
    }
    a = a + 1;
}
