public class Commands1 {
  public static int doubleSum (int a, int b) {
    return (2*(a+b));
  }

  public static String reverse (String input) {
    char[] in = input.toCharArray();
    int begin=0;
    int end=in.length-1;
    char temp;
    while(end>begin){
        temp = in[begin];
        in[begin]=in[end];
        in[end] = temp;
        end--;
        begin++;
    }
    return new String(in);
  }
}
