// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

part of convoweb;

/**
 *   Class TabbedPanel creates a container with two tabbed panels
 *   Usage:
 *     String tabOne = 'myTabOne';
 *     String tabTwo = 'myTabTwo';
 *     var tabContainer = query('#myTabCont');
 *     new TabbedPanel(tabContainer, tabOne, tabTwo);
 *     var tabOneID = query('#tabOneCont');
 *     var tabTwoID = query('#tabTwoCont');
 */

class TabbedPanel {

  DivElement _tabOneFocus;
  DivElement _tabOneReady;
  DivElement _tabTwoFocus;
  DivElement _tabTwoReady;
  DivElement _tabOneContent;
  DivElement _tabTwoContent;

  /***************************************************************
  * Constructor creates the tabbed panel for                     *
  * displaying two tabbed panels.                                *
  ****************************************************************/
  TabbedPanel(Element container, String tabOne, String tabTwo) {

    /**************************************************************
     * Create tab one 'focus' div. Set its name to String tabOne. *
     **************************************************************/
    _tabOneFocus = new DivElement();
    _tabOneFocus.attributes = ({
      "id": "tabOneFocus",
      "class": "tabbedPanelTab",
      "style": "display:block;"
    });
    _tabOneFocus.innerHtml = tabOne;
    container.nodes.add(_tabOneFocus);

    /***************************************************************
     * Create tab one 'ready' div.  Set its name to String tabOne. *
     ***************************************************************/
    _tabOneReady = new DivElement();
    _tabOneReady.attributes = ({
      "id": "tabOneReady",
      "class": "tabbedPanelTab",
      "style": "display:none;"
    });
    _tabOneReady.innerHtml = tabOne;
    container.nodes.add(_tabOneReady);

    /*****************************************************************
     * Create tab two 'focus' div.  Set its name to String tabTwo.   *
     *****************************************************************/
    _tabTwoFocus = new DivElement();
    _tabTwoFocus.attributes = ({
      "id": "tabTwoFocus",
      "class": "tabbedPanelTab",
      "style": "display:none;"
    });
    _tabTwoFocus.innerHtml = tabTwo;
    container.nodes.add(_tabTwoFocus);

    /*****************************************************************
     * Create tab two 'ready' div.  Set its name to String tabTwo.   *
     *****************************************************************/
    _tabTwoReady = new DivElement();
    _tabTwoReady.attributes = ({
      "id": "tabTwoReady",
      "class": "tabbedPanelTab",
      "style": "display:block;"
    });
    _tabTwoReady.innerHtml = tabTwo;
    container.nodes.add(_tabTwoReady);

    /****************************************************************
     * Create the blog feed div and give it an id of 'tabOneCont'.  *
     ****************************************************************/
    _tabOneContent = new DivElement();
    _tabOneContent.id = "tabOneCont";
    container.nodes.add(_tabOneContent);

    /****************************************************************
     * Create the Github feed div and give it an id of 'tabTwoCont'.*
     ****************************************************************/
    _tabTwoContent = new DivElement();
    _tabTwoContent.id = "tabTwoCont";
    container.nodes.add(_tabTwoContent);

    /*****************************************************************
     * Add event listeners to the two 'ready' tabs and call function *
     * changeDisplay() which is passed a display list that control   *
     * the state of the tabbed panel.                                *
     *****************************************************************/
    _tabOneReady.onClick.listen((e) {
      List _displayList = [_tabOneFocus,_tabTwoReady,_tabOneContent];
      _changeDisplay(_displayList);
    });

    _tabTwoReady.onClick.listen((e) {
      List _displayList = [_tabOneReady,_tabTwoFocus,_tabTwoContent];
      _changeDisplay(_displayList);
    });
  }

  /***************************************************************************
   * changeDisplay() controls the tabbed panel by deciding which divs should *
   * have their display set to 'block' and which should be set to 'none'.    *
   * This function is called by the listeners attached to each ready tab.    *
   ***************************************************************************/
  void _changeDisplay(List _displayList) {
    List _idList = [_tabOneFocus,_tabTwoFocus,_tabOneReady,
                  _tabTwoReady,_tabOneContent,_tabTwoContent];
    for(int i = 0; i < _idList.length; i++) {
      var block = false;
      for(int j = 0; j < _displayList.length; j++) {
         if(_idList[i] == _displayList[j]) {
            block = true;
            break;
            }
         }
      if (block) {
        _idList[i].style.display = "block";
      } else {
        _idList[i].style.display = "none";
      }
    }
  }
}
