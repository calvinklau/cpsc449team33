package methods;

import java.io.*;
import java.lang.*;
import java.lang.reflect.*;
import java.text.*;
import java.util.*;
import java.net.*;
import java.io.IOException;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

/**
 * Main class
 *
 * @author 	Bruce Laird, Calvin Lau, Matthew Armstrong, Michael de Grood, SanHa Kim
 */
public class Main {
  private static String synopsis = "Synopsis:\n  methods\n  methods { -h | -? | --help }+\n  methods {-v --verbose}* <jar-file> [<class-name>]\nArguments:\n  <jar-file>:   The .jar file that contains the class to load (see next line).\n  <class-name>: The fully qualified class name containing public static command methods to call. [Default=\"Commands\"]\nQualifiers:\n  -v --verbose: Print out detailed errors, warning, and tracking.\n  -h -? --help: Print out a detailed help message.\nSingle-char qualifiers may be grouped; long qualifiers may be truncated to unique prefixes and are not case sensitive.";
  public static boolean verboseFlag = false;
  private static int jarIndex = 0;
  private static int classIndex = 1;
  private static String jarFile = "";
  private static String className = "Commands";

  /**
   * Main function
   *
   * Error checks command line arguments, executes program according to arguments
   *
   * @param args 	Array of command line arguments
   */
  public static void main(String[] args) {
    // If there are no arguments/qualifiers on the command line, print the synopsis to sysout
    if (args.length == 0) {
      System.out.println(synopsis);
  	  System.exit(0);
    }

    // Filter out unrecognized qualifiers that begin with "--"
    if (args[0].startsWith("--") && !"help".contains(args[0].substring(2, args[0].length())) && !"verbose".contains(args[0].substring(2, args[0].length()))){
      System.err.println("Unrecognized qualifier: "+args[0]+".");
      System.err.println(synopsis);
      System.exit(-1);
    }

    // Filter out unrecognized qualifiers that begin with "-"
    if (args[0].startsWith("-") && !args[0].startsWith("--") && !args[0].startsWith("-v") && !args[0].startsWith("-h") && !args[0].startsWith("-?")) {
      System.err.println("Unrecognized qualifier \'" + args[0].substring(1, 2) + "\' in \'"+args[0]+"'.");
      System.err.println(synopsis);
      System.exit(-1);
    }

    // Process help qualifier (if any)
    if (args[0].startsWith("-h") || args[0].startsWith("-?") || "--help".contains(args[0]))
      processHelpQualifier(args);

    // Process verbose mode qualifier (if any)
    if (args[0].startsWith("-v") || "--verbose".contains(args[0]))
      processVerboseQualifier(args);

    // If there are more than 2 command line arguments (and no verbose mode qualifier), fatal error
    else if (!args[0].startsWith("-v") || !"--verbose".contains(args[0])) {
      if (args.length > 2) {
        System.err.println("This program takes at most two command line arguments.");
        System.err.println(synopsis);
        System.exit(-2);
      }
    }

    // Check if .jar file exists
    verifyJarFile(args);

    // Then check if the class exists
    verifyClassName(args);

    // Program will reach this point if all command line arguments are valid. Continue with normal program execution
    printStartUp();
    mainLoop();
  }

  /**
   * mainLoop function
   *
   */
  public static void mainLoop() {
    ProcessJar jar = new ProcessJar(jarFile);
    Class cls = jar.accessJar(className);
    ParseTree tree = new ParseTree();
	  Scanner s = new Scanner(System.in);
	  String str;
	  while(true) {
      System.out.print("> ");
      str = s.nextLine();
      switch (str){
        case "?":
          printStartUp();
          break;
        case "q":
          System.out.println("bye.");
  			  System.exit(0);
  			  break;
        case "v":
          verboseFlag = (!(verboseFlag));
  			  System.out.println("Verbose " + (verboseFlag ? "on." : "off."));
  			  break;
        case "f":
          jar.listMethods(cls);
          break;
        case "":
          break;
        default:
          try {
            String trimmed = str.trim();
            char[] charArray = trimmed.toCharArray();
            String firstChar = Character.toString(charArray[0]);
            String lastChar = Character.toString(charArray[charArray.length-1]);
            String[] noSpaces = null;
            int index = 0;
            int quoatationCount = 0;
            if (!firstChar.equals('(')) {
              if (firstChar.equals("\"")) {
                if (lastChar.equals("\"")) {
                  for (char i : charArray) {
                    if (Character.toString(i).equals("\"")) {
                      if (quoatationCount > 2) {
                        break;
                      }

                        quoatationCount++;
                        index++;
                        continue;
                    }


                    index++;
                  }
                  if (quoatationCount == 2) {
                    trimmed = trimmed.substring(1, trimmed.length()-1);
                    System.out.println(trimmed);
                    continue;
                  }
                }
              }
              else {
                if (trimmed.matches("^[0-9]*\\.?[0-9]*$")) {
                  if (!firstChar.equals(".")) {
                    System.out.println(trimmed);
                    continue;
                  }
                }
              }
            }

            tree.buildTree(str);
            Evaluator evaluate = new Evaluator(tree);
            evaluate.evaluateTree(tree.getRoot(), cls, jar, str);
            if (!tree.getRoot().getType().equals("func"))
              System.out.println(tree.getRoot().getData());
          }
          catch(ArithmeticException e) {
            System.out.println("Number exceeds Java number range");
            if(verboseFlag){
              System.out.println(e);
              for(StackTraceElement st : Thread.currentThread().getStackTrace()){
                System.out.println("	at " + st);
              }
            }
          }
          catch(Exception e) {
    			  if(verboseFlag){
              System.out.println(e);
              for(StackTraceElement st : Thread.currentThread().getStackTrace()){
                System.out.println("	at " + st);
              }
            }
          }
      }
    }
  }

  /**
   * processHelpQualifier() function
   *
   * Processes help qualifier
   *
   * @param args Array of command line arguments
   */
  public static void processHelpQualifier(String[] args) {
    /* Check for 'help' qualifier
     * If any other argument appears with a help qualifier:
     *  1. Print error text and synopsis to syserr
     *  2. Exit with code -4
     * Else (Valid help command):
     *  1. Print the help menu to sysout
     */
    if (args.length > 1) {
      System.err.println("Qualifier --help (-h, -?) should not appear with any command-line arguments.");
      System.err.println(synopsis);
      System.exit(-4);
    }
    else
      printHelpMenu();
      System.exit(0);
  }

  /**
   * processVerboseQualifier() function
   *
   * Processes verbose mode qualifier
   *
   * @param args Array of command line arguments
   */
  public static void processVerboseQualifier(String[] args) {
    // If there are more than three arguments (including the verbose mode qualifier), fatal error
    if (args.length > 3) {
      System.err.println("This program takes at most two command line arguments.");
      System.err.println(synopsis);
      System.exit(-2);
    }
    // If a verbose mode qualifier is the only command line argument, fatal error
    if (args.length == 1) {
      System.err.println("This program requires a jar file as the first command line argument (after any qualifiers).");
      System.err.println(synopsis);
      System.exit(-3);
    }

    // Valid use of a verbose mode qualifier = set the verboseFlag
    // Increment jarIndex and classIndex in order to extract jar file and class name from the correct index in args
    verboseFlag = true;
    jarIndex++;
    classIndex++;
  }

  /**
   * verifyJarFile() function
   *
   * Verifies that the passed .jar file exists
   *
   * @param args Array of command line arguments
   */
  public static void verifyJarFile(String[] args) {
    try {
      if (args[jarIndex].endsWith(".jar")) {
        File jarFile = new File(args[jarIndex]);

        // If .jar file does not exist, fatal error
        if (!jarFile.exists()) {
          System.err.println("Could not load jar file: " + args[jarIndex]);
          System.exit(-5);
        }
      }
      // If user passes a non .jar file as the first argument, fatal error
      else {
        System.err.println("This program requires a jar file as the first command line argument (after any qualifiers).");
        System.exit(-3);
      }

      jarFile = args[jarIndex];
    }
    catch(Exception e) {System.out.println(e.getMessage());}
  }

  /**
   * verifyClassName() function
   *
   * Verifies that the passed class name exists in the .jar file. If the class name does exist,
   *
   * @param args Array of command line arguments
   */
  public static void verifyClassName(String[] args) {
    try {
      // If the class name is passed as an argument, verify that class name exists. Otherwise, verify that the default "Commands.class" exists
      if ((verboseFlag && args.length == 3) || (!verboseFlag && args.length == 2)) {
        className = args[classIndex];
      }

      JarFile jarName = new JarFile(args[jarIndex]);
      Enumeration allEntries = jarName.entries();
      while (allEntries.hasMoreElements()) {
        JarEntry entry = (JarEntry) allEntries.nextElement();
        String name = entry.getName();

        // If the passed class name argument matches one of the class files in the .jar file, begin normal program execution
        if (name.equals(className+".class")) {
          return;
        }

        // If there are no more class files to parse through in the .jar file and the class name argument has not been matched, fatal error
        if (!name.equals(className) && !allEntries.hasMoreElements()) {
          System.err.println("Could not find class: " + args[classIndex]);
          System.exit(-6);
        }
      }
    }
    catch(Exception e) {System.out.println(e.getMessage());}
  }

  /**
   * printStartUp function
   *
   * Called during normal program execution
   */
  public static void printStartUp() {
    System.out.println("q           : Quit the program.");
    System.out.println("v           : Toggle verbose mode (stack traces).");
    System.out.println("f           : List all known functions.");
    System.out.println("?           : Print this helpful text.");
    System.out.println("<expression>: Evaluate the expression.");
    System.out.println("Expressions can be integers, floats, strings (surrounded in double quotes) or function");
    System.out.println("calls of the form '(identifier {expression}*)'.");
  }

  /**
   * printHelpMenu function
   *
   * Called in processHelpQualifier() function in the event of a valid help qualifier command line argument
   */
  public static void printHelpMenu() {
    System.out.println("Synopsis:");
    System.out.println("  methods");
    System.out.println("  methods { -h | -? | --help }+");
    System.out.println("  methods {-v --verbose}* <jar-file> [<class-name>]");
    System.out.println("Arguments:");
    System.out.println("  <jar-file>:   The .jar file that contains the class to load (see next line).");
    System.out.println("  <class-name>: The fully qualified class name containing public static command methods to call. [Default=\"Commands\"]");
    System.out.println("Qualifiers:");
    System.out.println("  -v --verbose: Print out detailed errors, warning, and tracking.");
    System.out.println("  -h -? --help: Print out a detailed help message.");
    System.out.println("Single-char qualifiers may be grouped; long qualifiers may be truncated to unique prefixes and are not case sensitive.");
    System.out.println();
    System.out.println("This program interprets commands of the format '(<method> {arg}*)' on the command line, finds corresponding methods in <class-name>, and executes them, printing the result to sysout.");
  }
}
