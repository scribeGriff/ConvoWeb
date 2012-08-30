/* ************************************************************** *
 *   Add HTML to an element efficiently                           *
 *   Library: ConvoWeb (c) 2012 scribeGriff                       *
 * ************************************************************** */

String addHTML(String htmlstring, Element element) {
  element.insertAdjacentHTML('beforeend', '${htmlstring}<br/>');
}
