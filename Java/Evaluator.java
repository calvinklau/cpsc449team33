package methods;

import java.util.*;
import java.lang.reflect.*;
import java.text.*;

/**
 * Evaluator class
 *
 * @author 	Bruce Laird, Calvin Lau, Matthew Armstrong, Michael de Grood, SanHa Kim
 */
public class Evaluator {
  private ParseTree tree;
  public Evaluator(ParseTree tree) {
    this.tree = tree;
  }

  /**
    * Evaluates the entire parse tree
    *
    * @param node The node at the top of the tree
    * @param cls The class containing all concrete methods
    * @param jarProcessor The object of the ProcessJar class that processes the jar file
    * @param exp The entered expression
    * @throws ParseException When a method entered does not match any methods in the class
    */
  public void evaluateTree(Node node, Class cls, ProcessJar jarProcessor, String exp) throws ParseException {
    String errorMessage = "Matching function for '(";
    String type = "";
    for (Node child : node.getChildren()) {
      if (isBottom(child) && child.getType().equals("func")) {
        Method currentMethod = jarProcessor.validMethod(child.getData(), cls, getValues(child));
        if (currentMethod == null) {
          errorMessage += child.getData();
          for (int i=0; i<child.getChildren().size(); i++) {
            type = child.getChild(i).getType();
            switch(type) {
              case "Integer":
                type = "int";
                break;
              case "Float":
                type = "float";
                break;
              case "String":
                type = "string";
                break;
            }
            errorMessage += " "+type;
          }
          errorMessage += ")' not found at offset "+child.getNodeIndex();
          System.out.println(errorMessage);
          System.out.println(exp);
          System.out.print(tree.getArrow(child.getNodeIndex()+1));
          throw new ParseException(errorMessage, child.getNodeIndex());
        }
        evaluateNode(child, cls, currentMethod);
      }
      else if (!isBottom(child) && child.getType().equals("func")) {
        evaluateTree(child, cls, jarProcessor, exp);
      }
    }

    Method rootMethod = jarProcessor.validMethod(node.getData(), cls, getValues(node));
    errorMessage = "Matching function for '(";
    if (rootMethod == null) {
      errorMessage += node.getData();
      for (int i=0; i<node.getChildren().size(); i++) {
        type = node.getChild(i).getType();
        switch(type) {
          case "Integer":
            type = "int";
            break;
          case "Float":
            type = "float";
            break;
          case "String":
            type = "string";
            break;
        }
        errorMessage += " "+type;
      }
      errorMessage += ")' not found at offset "+node.getNodeIndex();
      System.out.println(errorMessage);
      System.out.println(exp);
      System.out.print(tree.getArrow(node.getNodeIndex()+1));
      throw new ParseException(errorMessage, node.getNodeIndex());
    }

    evaluateNode(node, cls, rootMethod);
  }

  /**
    * Evaluates a function node using its children (if any)
    *
    * @param funcionNode The node to be evaluated
    * @param cls The class containing all concrete methods
    * @param m The method returned from the class
    */
  public void evaluateNode(Node functionNode, Class cls, Method m) {
    try {
      Object[] params = new Object[functionNode.getChildren().size()];
      ArrayList<Node> nodeArgs = functionNode.getChildren();

      for (int i=0; i<nodeArgs.size(); i++) {
        String type = nodeArgs.get(i).getType();

        switch(type) {
          case "int":
            params[i] = Integer.valueOf(nodeArgs.get(i).getData());
            break;
          case "float":
            params[i] = Float.valueOf(nodeArgs.get(i).getData());
            break;
          case "String":
            params[i] = nodeArgs.get(i).getData();
            break;
        }
      }

      Object res = m.invoke(cls, params);
      String result = res.toString();
      String returnType = m.getReturnType().getName();

      switch(returnType) {
        case "java.lang.Integer":
          returnType = "Integer";
          break;
        case "java.lang.Float":
          returnType = "Float";
          break;
        case "java.lang.String":
          returnType = "String";
          break;
      }

    functionNode.removeChildren();
    functionNode.setType(returnType);
    functionNode.setData(result);
    }
    catch(Exception e){throw new ArithmeticException();}
  }

  /**
    * Returns all children of type value of a node
    *
    * @param node The parent node of the children
    * @return The ArrayList of all children nodes
    */
  public ArrayList<Node> getValues(Node node) {
    ArrayList<Node> values = new ArrayList<Node>();
    for (int i=0; i<node.getChildren().size(); i++) {
      Node currentNode = node.getChild(i);
      if (!currentNode.getType().equals("func")) {
          values.add(currentNode);
      }
    }

    return values;

  }

  /**
    * Returns all children of type function of a node
    *
    * @param node The parent node of the children
    * @return The ArrayList of all function nodes
    */
  public ArrayList<Node> getFunctions(Node node) {
    ArrayList<Node> funcs = new ArrayList<Node>();
    for (int i=0; i<node.getChildren().size(); i++) {
      Node currentNode = node.getChild(i);
      if (currentNode.getType().equals("func")) {
          funcs.add(currentNode);
          funcs.addAll(getFunctions(currentNode));
      }
    }
    return funcs;
  }

  /**
    * Determines if a node has no function nodes as a child
    *
    * @param node The parent node of the children
    * @return Whether or not the node has function nodes as a children or not
    */
  public boolean isBottom(Node node) {
    for (int i=0; i<node.getChildren().size(); i++) {
      if (node.getChild(i).getType().equals("func")) {
        return false;
      }
    }
    return true;
  }
}
