package methods;

import java.util.*;

/**
 * Node class
 *
 * @author 	Bruce Laird, Calvin Lau, Matthew Armstrong, Michael de Grood, SanHa Kim
 */
public class Node {
  private Node parent;
  private ArrayList<Node> children;
  private String data;
  // Types: func, int, float, string
  private String type;
  private int nodeIndex;

  /**
    * Node default constructor
    *
    */
  public Node() {
    this.parent = null;
    this.children = new ArrayList<Node>();
    this.data = "null";
    this.type = null;
    this.nodeIndex = -1;
  }

  /**
    * ParseTree constructor
    *
    * @param parent The parent of this node
    * @param data The type of data of this node
    * @param type The data of this node
    * @param nodeIndex The index of this node
    */
  public Node(Node parent, String data, String type, int nodeIndex) {
    this.parent = parent;
    this.children = new ArrayList<Node>();
    this.data = data;
    this.type = type;
    this.nodeIndex = nodeIndex;
  }

  /**
    * Returns the parent of this node
    *
    * @return The parent node
    */
  public Node getParent() {
    return this.parent;
  }

  /**
    * Sets the parent of this node
    *
    */
  public void setParent(Node newParent) {
    this.parent = newParent;
  }

  /**
    * Returns the children of this node
    *
    * @return The children of this node
    */
  public ArrayList<Node> getChildren() {
    return this.children;
  }

  /**
    * Returns the child of this node at index
    *
    * @param index The index in the ArrayList where the wanted child is located
    */
  public Node getChild(int index) {
    return this.children.get(index);
  }

  /**
    * Adds a child to this node
    *
    */
  public void addChild(Node newChild) {
    this.children.add(newChild);
  }

  /**
    * Removes/deletes the children of this node
    *
    */
  public void removeChildren() {
    this.children = null;
  }

  /**
    * Returns the data of this node
    *
    * @return The data of this node
    */
  public String getData() {
    return this.data;
  }

  /**
    * Sets the data of this node
    *
    * @param newData The new data for this node
    */
  public void setData(String newData) {
    this.data = newData;
  }

  /**
    * Returns the type of this node
    *
    */
  public String getType() {
    return this.type;
  }

  /**
    * Sets the type of this node
    *
    * @param newType The new type for this node
    */
  public void setType(String newType) {
    this.type = newType;
  }

  /**
    * Returns the index of this node
    *
    */
  public int getNodeIndex() {
    return this.nodeIndex;
  }

  /**
    * Returns the string representation of this node
    *
    */
  public String toString(){
   return ("Node Data: " + this.data + " | Node Type: " + this.type + " | Node Index: " + this.nodeIndex);
  }
}
