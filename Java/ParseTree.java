package methods;

import java.util.*;
import java.text.*;

/**
 * ParseTree class
 *
 * @author 	Bruce Laird, Calvin Lau, Matthew Armstrong, Michael de Grood, SanHa Kim
 */
public class ParseTree {
  private Node root;
  private Node currentNode;


  /**
    * ParseTree default constructor
    *
    */
  public ParseTree() {
	  root = new Node();
	  currentNode = root;
  }

  /**
    * ParseTree constructor
    *
    * @param data The data of the root node
    * @param type The type of data of the root node
    */
  public ParseTree(String data, String type) {
	  root = new Node();
	  currentNode = root;
  }

  /**
  *Returns the root of the tree
  *@return the root node of the tree
  */
  public Node getRoot() {
    return this.root;
  }

  /**
  *Adds a node to the tree
  *The node is added as a child to the current node, and the current node is changed to the node that was just added
  *
  *@param data The data to be added to the node
  *@param type The type of data to be added to the node
  *@param index Where this node was found in the parsed string
  */
  public void addNode(String data, String type, int index) {
	 Node newNode = new Node(currentNode, data, type, index);
	 currentNode.addChild(newNode);

	 currentNode = newNode;
  }


  /**
  *Changes the current node to the parent of the current node.
  */
  public void toParent() {
    if (currentNode.getParent() == null) {
      System.out.println("This node does not have a parent");
      return;
    }
	  currentNode = currentNode.getParent();
  }

  /**
  *Changes the current node to one of the children of the current node
  *
  *@param index The index of the node to be switched to
  */
  public void toChild(int index) {
	  try{
		  currentNode = currentNode.getChild(index);
	  }
	  catch(Exception e){
		  System.out.println("Current node not changed");
	  }
  }

  public int size(Node n) {
    int i=0;
    for (Node c : n.getChildren()) {
      if (c.getType().equals("func")) {
        i += size(c);
      }
      else {
        i++;
      }
    }

    return i+1;
  }
  /**
  *Prints the current node
  */
  public void printNode() {
    System.out.println(currentNode.toString());
  }

 /**
 *Prints the tree
 */
  public void printTree(){
  	  Stack<Node> s = new Stack<Node>();
  	  s.push(this.root);

  	  while(!(s.isEmpty())){
    		Node current = s.peek();
    		System.out.println(current.toString());

    		s.pop();

    		ArrayList<Node> currentChildren = current.getChildren();

    		for(Node n : currentChildren){
    			s.push(n);
    		}
  	  }
    }

  /**
  *Gets an appropriately formatted arrow for error printing
  *
  *@param s The number of dashes in the arrow
  *@return The arrow as a String
  */
  public String getArrow(int s){
	  String arrow = "";
	  for(int i = 1; i < s; i++){
		  arrow = arrow + "-";
	  }
	  arrow = arrow + "^\n";

	  return arrow;
  }

  /**
  *Parses a string and builds a parse tree based on the given string
  *
  *@param exp The string to be parsed
  *@throws ParseException if an error occurs in parsing
  */
  public void buildTree (String exp) throws ParseException{
    root = new Node();
    this.currentNode = root;
    int index = 0;
    int bracketCount = 0;
    boolean stringFlag = false;
    int stringIndex = -1;
    boolean functionFlag = false;
    int functionIndex = -1;
    boolean rootFlag = false;
    boolean numFlag = false;
    int numIndex = -1;
    int floatCount = 0;
    ArrayList<Character> charArray = new ArrayList<Character>();

    for (char i : exp.toCharArray()) {
      if (i == '(') {
		  if(stringFlag && !functionFlag){
			  charArray.add(i);
		  }

		  else if(bracketCount == 0 && rootFlag){ //Left bracket is found after expression
			 System.out.println("Encountered incorrect token at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			stringFlag = false;
			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
		 }

		 else if(functionFlag){ //Right bracket cannot be found in function name
			System.out.println("Encountered incorrect bracket at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			  throw new ParseException("Encountered incorrect bracket at offset " + (index), index);
		 }

		 else{
			functionFlag = true;
			functionIndex = index;
			bracketCount++;
		 }
      }

      else if (i == ')') {
		  if(bracketCount == 0 && rootFlag){ //Right bracket found after expression is finished
        System.out.println("Encountered incorrect token at offset " + (index));
  			System.out.println(exp);
  			System.out.print(getArrow(index+1));
  			bracketCount = 0;
  			stringFlag = false;
  			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
		  }

		 if(!stringFlag){
        bracketCount--;
		 }

     if (numFlag) {
      numFlag = false;
      floatCount = 0;

      String st = "";
      for (char j : charArray) {
        st += Character.toString(j);
      }

      Node n;

      if (st.contains("."))
        n = new Node(currentNode, st, "float", index-charArray.size());

      else
        n = new Node(currentNode, st, "int", index-charArray.size());

      currentNode.addChild(n);
      if (!rootFlag) {
        root = currentNode;
        rootFlag = true;
      }
      charArray = new ArrayList<Character>();
    }

		if(functionFlag && stringFlag){
			functionFlag = false;
			stringFlag = false;
			bracketCount--;
			String st = "";

			for(char j : charArray){
				st += Character.toString(j);
			}

			Node n = new Node(currentNode, st, "func", index-charArray.size());

			if(!rootFlag){
				root = n;
				rootFlag = true;
			}
			else{
				currentNode.addChild(n);
			}

			charArray = new ArrayList<Character>();


		}

		else if(stringFlag && !functionFlag){
			charArray.add(i);
      index++;
			continue;
		}

    if (currentNode == root){
      if(bracketCount < 0){ //No left bracket
  		  System.out.println("Encountered incorrect bracket at offset " + (index));
  		  System.out.println(exp);
  		  System.out.print(getArrow(index+1));
  			  throw new ParseException("Encountered incorrect bracket at offset " + (index), index);
		  }
			index++;
      continue;
		}

    else{currentNode = currentNode.getParent();}
    }

    // If element is a quotation mark
    else if (i == '\"') {
      if(bracketCount == 0 && rootFlag){ //Quotation mark is found after expression
        System.out.println("Encountered incorrect token at offset " + (index));
        System.out.println(exp);
        System.out.print(getArrow(index+1));
        bracketCount = 0;
        stringFlag = false;
          throw new ParseException("Encountered incorrect token at offset " + (index), index);
		 }

		 if(functionFlag){ //No quotation marks in function
        System.out.println("Encountered incorrect token at offset " + (index));
        System.out.println(exp);
        System.out.print(getArrow(index+1));
        bracketCount = 0;
        stringFlag = false;
        throw new ParseException("Encountered incorrect token at offset " + (index), index);
		 }

     if (stringFlag) {
        stringFlag = false;
        stringIndex = index;

        String st = "";
        for (char j : charArray) {
          st += Character.toString(j);
        }

        Node n = new Node(currentNode, st, "String", index-charArray.size());
        currentNode.addChild(n);
        if (!rootFlag) {
          root = currentNode;
          rootFlag = true;
        }

        charArray = new ArrayList<Character>();
      }
      else {
        stringFlag = true;
        stringIndex = index;
      }
    }

      // If element is neither whitespace or a quotation
      else if (!(i == ' ') && !(i == '\t')) {
		 if(bracketCount == 0 && rootFlag){ //Something appeared after the first function is evaluated
			 System.out.println("Encountered incorrect token at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			stringFlag = false;
			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
		 }
        if (functionFlag) {
          if (!(Character.isLetter(i)) && !(Character.toString(i).equals("_")) && !(Character.isDigit(i))) { //Incorrect symbol for function name
			  System.out.println("Encountered incorrect token at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			stringFlag = false;
			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
          }

          stringFlag = true;
		  stringIndex = index;
          charArray.add(i);
        }

        else if (stringFlag) {
          charArray.add(i);
        }

		else if(Character.toString(i).equals("-") && !numFlag){
			numFlag = true;
			numIndex = index;
			charArray.add(i);
		}

		else if(Character.toString(i).equals("-") && numFlag){
		  System.out.println("Encountered incorrect token at offset " + (index));
		  System.out.println(exp);
		  System.out.print(getArrow(index+1));
		  bracketCount = 0;
		  throw new ParseException("Encountered incorrect token at offset " + (index), index);
		}

        else if (Character.isDigit(i) && numFlag) {
          charArray.add(i);
        }

        else if (Character.isDigit(i) && !numFlag) {
          numFlag = true;
		  numIndex = index;
          charArray.add(i);
        }

        else if (Character.toString(i).equals(".") && !numFlag) {
          // Illegal float value entry
		  System.out.println("Encountered incorrect token at offset " + (index));
		  System.out.println(exp);
		  System.out.print(getArrow(index+1));
		  bracketCount = 0;
			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
        }

        else if (Character.toString(i).equals(".") && numFlag) {
			floatCount++;
			if(floatCount > 1){ //Need to have zero or one periods
				System.out.println("Encountered incorrect token at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			stringFlag = false;
			throw new ParseException("Encountered incorrect token at offset " + (index), index);
			}
          charArray.add(i);
        }

		else{ //Catch-all for unexpected characters
			System.out.println("Encountered incorrect token at offset " + (index));
			System.out.println(exp);
			System.out.print(getArrow(index+1));
			bracketCount = 0;
			stringFlag = false;
			  throw new ParseException("Encountered incorrect token at offset " + (index), index);
		}
      }

      // If element is whitespace
      else if (i == ' ' || i == '\t') {
        if (functionFlag && stringFlag) {
          functionFlag = false;
          stringFlag = false;
		  stringIndex = -1;

          String st = "";
          for (char j : charArray) {
            st += Character.toString(j);
          }

          Node n = new Node(currentNode, st, "func", index-charArray.size());
          currentNode.addChild(n);
          currentNode = n;
          if (!rootFlag) {
            root = currentNode;
            rootFlag = true;
          }
          charArray = new ArrayList<Character>();
        }

        else if (numFlag) {
          numFlag = false;
		  floatCount = 0;

          String st = "";
          for (char j : charArray) {
            st += Character.toString(j);
          }

          Node n;
          if (st.contains(".")){
            n = new Node(currentNode, st, "float", index-charArray.size());
		  }

          else
            n = new Node(currentNode, st, "int", index-charArray.size());

          currentNode.addChild(n);
          if (!rootFlag) {
            root = currentNode;
            rootFlag = true;
          }
          charArray = new ArrayList<Character>();
        }

        else if (stringFlag) {
          charArray.add(i);
        }


      }

	  if(bracketCount < 0){ //missing left bracket
		  System.out.println("Encountered incorrect bracket at offset " + (index));
		  System.out.println(exp);
		  System.out.print(getArrow(index));
		  throw new ParseException("Encountered incorrect bracket at offset " + (index), index);
	  }

      index++;
    }

    if (stringFlag || bracketCount > 0) {
      if (stringFlag) { //missing end quotation mark
		  String message = "Encountered end-of-input while reading string beginning at offset "  + stringIndex;
		  System.out.println(message + " at offset " + (index));
		  System.out.println(exp);
		  System.out.print(getArrow(index+1));
		  throw new ParseException(message, index);
    }

	  else if (bracketCount > 0){ //missing end bracket
		  String message = "Encountered end-of-input while reading string beginning at offset " + functionIndex;
		  System.out.println(message + " at offset " + (index));
		  System.out.println(exp);
		  System.out.print(getArrow(index+1));
		  throw new ParseException(message, index);
	  }

    }
  }
}
