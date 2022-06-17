import 'package:pdftron_flutter/pdftron_flutter.dart';

Config getConfig() {
  Config config = new Config();
  
  config.annotationToolbars = [
    DefaultToolbars.view,
    DefaultToolbars.annotate,
  ];
  
  config.disabledElements = [
    Buttons.printButton,
    Buttons.saveCopyButton,
    Buttons.editPagesButton,
    Buttons.shareButton,
    Buttons.viewLayersButton,
    //Buttons.viewControlsButton,
  ];
  
  config.bottomToolbar = [
    Buttons.viewControlsButton,
    Buttons.searchButton,
    Buttons.listsButton,
    Buttons.outlineListButton,
  ];
  
  config.disabledTools = [
    Tools.annotationSmartPen,
    Tools.annotationCreateFreeHand,
    Tools.annotationCreateTextStrikeout,
    Tools.annotationCreateTextSquiggly,
    Tools.annotationCreateSticky,
    Tools.annotationCreateCallout,
    Tools.multiSelect,
    Tools.annotationLasso,
    Tools.annotationEdit
  ];
  
  config.annotationToolbarAlignment = ToolbarAlignment.Start;               
  config.outlineListEditingEnabled = false;
  
  return config;
}

