package methods;

import java.io.*;
import java.lang.*;
import java.text.*;
import java.util.*;
import java.net.*;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.lang.reflect.Method;

/**
 * ProcessJar class
 *
 * @author 	Bruce Laird, Calvin Lau, Matthew Armstrong, Michael de Grood, SanHa Kim
 */
public class ProcessJar {
  private String jar;

  /**
    * ProcessJar constructor
    *
    * @param jarName The name of the jar file
    */
  public ProcessJar(String jarName) {
    this.jar = jarName;
  }

  /**
    * Evaluates a function node using its children (if any)
    *
    * @param funcionNode The node to be evaluated
    * @param cls The class containing all concrete methods
    * @return The corresponding class contained in the jar file
    */
  public Class accessJar(String className) {
    Class cls = null;
    try {
        File file = new File (this.jar);
        URL url = file.toURI().toURL();
        URL[] urls = new URL[] {url};
  			ClassLoader cl = new URLClassLoader(urls);
  			cls = cl.loadClass(className);
    }
    catch (Exception ex) {}

    return cls;
  }

  /**
    * Checks if the entered method exists in the class
    *
    * @param method The name of the method to be checked
    * @param cls The class containing all concrete methods
    * @param methodParams The children of the function node
    * @return The method object of the concrete method inside the class, null otherwise
    */
  public Method validMethod(String method, Class c, ArrayList<Node> methodParams) {
    Method[] methods = c.getDeclaredMethods();
    ArrayList<Method> matchedNames = new ArrayList<Method>();

    for(Method item : methods) {
      if (item.getName().equals(method)) {
        matchedNames.add(item);
      }
    }

    for (Method item2 : matchedNames) {
      Class[] paramTypes = item2.getParameterTypes();
      if(methodParams.size() == 0){
        if(paramTypes.length != 0){
          continue;
        }
        return item2;
      }

      for (int i = 0; i < paramTypes.length; i++){
        String currentParam = methodParams.get(i).getType();
        String expectedParam = paramTypes[i].getName();

        if(paramTypes.length != methodParams.size()){
          break;
        }

        else if(expectedParam.equals("java.lang.String")) {
          if (!currentParam.equals("String")) {
            break;
          }
        }
        else if(expectedParam.equals("java.lang.Integer")) {
          if (!currentParam.equals("Integer") && !currentParam.equals("int")) {
            break;
          }
        }
        else if(expectedParam.equals("java.lang.Float")) {
          if (!currentParam.equals("Float") && !currentParam.equals("float")) {
            break;
          }
        }

        else if(!expectedParam.equals(currentParam)) {
            break;
        }

        if(i == (paramTypes.length-1))
          return item2;
      }
    }
    return null;
  }

  /**
	* listMethods
	* Lists all the methods in the reflected class, along with their parameters and the return types
	* @param c The class that is being looked at
	*/
	public void listMethods(Class c) {
		Method[] methods = c.getDeclaredMethods(); //get a list of all methods in the class

		loop:
		for(Method item : methods){
			Class[] params = item.getParameterTypes(); //get the parameters from the method being looked at

			//check if the return types are correct
			if(item.getReturnType().getName() == "int" || item.getReturnType().getName() == "float" || item.getReturnType().getName() == "java.lang.String"  || item.getReturnType().getName() == "java.lang.Integer"  || item.getReturnType().getName() == "java.lang.Float") {
  			for(Class par : params) {
  				if(par.getName() != "int" && par.getName() != "float" && par.getName() != "java.lang.String"  && par.getName() != "java.lang.Integer"  && par.getName() != "java.lang.Float"){ //check if the parameters are of the correct type
  					continue loop;
  				}
  			}

  			System.out.print("(");
  			System.out.print(item.getName()); //print the name of the method


  			for(Class par : params) { //print the list of parameters
  				if(par.getName() == "java.lang.String") {
  					System.out.print(" string");
  				}
  				else if(par.getName() == "java.lang.Integer") {
  					System.out.print(" int");
  				}
  				else if(par.getName() == "java.lang.Float") {
  					System.out.print(" float");
  				}
  				else {
  					System.out.print(" " + par.getName());
  				}
  			}

  			System.out.print(") : ");

  			if(item.getReturnType().getName() == "java.lang.String" ){ //print the return type
  				System.out.println("string");
  			}
  			else if(item.getReturnType().getName() == "java.lang.Integer") {
  				System.out.println("int");
  			}
  			else if(item.getReturnType().getName() == "java.lang.Float") {
  				System.out.println("float");
  			}
  			else {
  				System.out.println(item.getReturnType().getName());
  			}

			}

		}
	}
}
