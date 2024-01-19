import CSI 1.0
import QtQuick 2.0
import Qt5Compat.GraphicalEffects

import '../Widgets' as Widgets

//--------------------------------------------------------------------------------------------------------------------
//  DECK HEADER
//--------------------------------------------------------------------------------------------------------------------

Item {
  id: deck_header
  
  // QML-only deck types
  readonly property int thruDeckType:  4

  // Placeholder variables for properties that have to be set in the elements for completeness - but are actually set
  // in the states
  readonly property int    _intSetInState:    0

  // Here all the properties defining the content of the DeckHeader are listed. They are set in DeckView.
  property int    deck_Id:           0
  property int    deckId:           deck_Id
  property string headerState:      "large" // this property is used to set the state of the header (large/small)
  
  readonly property variant deckLetters:        ["A",                         "B",                          "C",                  "D"                 ]
  readonly property variant textColors:         [colors.colorDeckBlueBright,  colors.colorDeckBlueBright,   colors.colorGrey232,  colors.colorGrey232 ]
  readonly property variant darkerTextColors:   [colors.colorDeckBlueDark,    colors.colorDeckBlueDark,     colors.colorGrey72,   colors.colorGrey72  ]
  // color for empty cover bg
  readonly property variant coverBgEmptyColors: [colors.colorDeckBlueDark,    colors.colorDeckBlueDark,     colors.colorGrey48,   colors.colorGrey48  ]
  // color for empty cover circles
  readonly property variant circleEmptyColors:  [colors.rgba(0, 37, 54, 255),  colors.rgba(0,  37, 54, 255),                       colors.colorGrey24,   colors.colorGrey24  ]

  readonly property variant loopText:           ["/32", "/16", "1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32"]
  readonly property variant emptyDeckCoverColor:["Blue", "Blue", "White", "White"] // deckId = 0,1,2,3

  // these variables can not be changed from outside
  readonly property int speed: 40  // Transition speed
  readonly property int smallHeaderHeight: 20
  readonly property int mediumHeaderHeight: 24
  readonly property int largeHeaderHeight: 40

  readonly property int rightFieldMargin: 2
  readonly property int fieldHeight:      20
  readonly property int fieldWidth:       78
  readonly property int topRowHeight:     24
  readonly property int bottomRowsHeight: 19

  readonly property bool   isLoaded:    top_left_text.isLoaded
  readonly property int    deckType:    deckTypeProperty.value
  readonly property int    isInSync:    top_left_text.isInSync
  readonly property int    isMaster:    top_left_text.isMaster
  readonly property double syncPhase:   (headerPropertySyncPhase.value*2.0).toFixed(2)
  readonly property int    loopSizePos: headerPropertyLoopSize.value

  function hasTrackStyleHeader(deckType)      { return (deckType == DeckType.Track  || deckType == DeckType.Stem);  }

  // PROPERTY SELECTION
  // IMPORTANT: See 'stateMapping' in DeckHeaderText.qml for the correct Mapping from
  //            the state-enum in c++ to the corresponding state
  // NOTE: For now, we set fix states in the DeckHeader! But we wanna be able to
  //       change the states.
  property int topLeftState:      0                                 // headerSettingTopLeft.value
  property int topMiddleState:    hasTrackStyleHeader(deckType) ? 14 : 29 // headerSettingTopMid.value
  property int topRightState:     hasTrackStyleHeader(deckType) ? 17 : 30 // headerSettingTopRight.value

  property int middleLeftState:   prefs.middleLeftText                                 // headerSettingMidLeft.value
  property int middleCenterState: hasTrackStyleHeader(deckType) ? prefs.middleCenterText : 29 // headerSettingMidMid.value
  property int middleRightState:  prefs.middleRightText                                // headerSettingMidRight.value

  property int bottomLeftState:   prefs.bottomLeftText
  property int bottomCenterState: prefs.bottomCenterText
  property int bottomRightState:  prefs.bottomRightText

  height: largeHeaderHeight
  clip: false //true
  Behavior on height { NumberAnimation { duration: speed } }

  readonly property int warningTypeNone:    0
  readonly property int warningTypeWarning: 1
  readonly property int warningTypeError:   2

  property bool isError:   (deckHeaderWarningType.value == warningTypeError)
  

  //--------------------------------------------------------------------------------------------------------------------
  // Helper function
  function toInt(val) { return parseInt(val); }

  //--------------------------------------------------------------------------------------------------------------------
  //  DECK PROPERTIES
  //--------------------------------------------------------------------------------------------------------------------

  AppProperty { id: propSyncMasterDeck; path: "app.traktor.masterclock.source_id" }
  AppProperty { id: keyDisplay;         path: "app.traktor.decks." + (deckId+1) + ".track.key.resulting.precise" }

  AppProperty { id: propElapsedTime;    path: "app.traktor.decks." + (deckId+1) + ".track.player.elapsed_time"; } 
  AppProperty { id: propNextCuePoint;   path: "app.traktor.decks." + (deckId+1) + ".track.player.next_cue_point"; }
  AppProperty { id: propMixerBpm;       path: "app.traktor.decks." + (deckId+1) + ".tempo.base_bpm" }

  AppProperty { id: deckTypeProperty;           path: "app.traktor.decks." + (deck_Id+1) + ".type" }

  AppProperty { id: directThru;                 path: "app.traktor.decks." + (deck_Id+1) + ".direct_thru"; onValueChanged: { updateHeader() } }
  AppProperty { id: headerPropertyCover;        path: "app.traktor.decks." + (deck_Id+1) + ".content.cover_md5" }
  AppProperty { id: headerPropertySyncPhase;    path: "app.traktor.decks." + (deck_Id+1) + ".tempo.phase"; }
  AppProperty { id: headerPropertyLoopActive;   path: "app.traktor.decks." + (deck_Id+1) + ".loop.active"; }
  AppProperty { id: headerPropertyLoopSize;     path: "app.traktor.decks." + (deck_Id+1) + ".loop.size"; }
  AppProperty { id: keyLockEnabled;             path: "app.traktor.decks." + (deck_Id+1) + ".track.key.lock_enabled" }
  
  AppProperty { id: deckHeaderWarningActive;       path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".active"; }
  AppProperty { id: deckHeaderWarningType;         path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".type";   }
  AppProperty { id: deckHeaderWarningMessage;      path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".long";   }
  AppProperty { id: deckHeaderWarningShortMessage; path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".short";  }

  AppProperty { id: mixerFX;       path: "app.traktor.mixer.channels." + (deck_Id+1) + ".fx.select" }
  AppProperty { id: mixerFXOn;     path: "app.traktor.mixer.channels." + (deck_Id+1) + ".fx.on" }

  AppProperty { id: deckRunning;   path: "app.traktor.decks." + (deck_Id+1) + ".running" } 

  //--------------------------------------------------------------------------------------------------------------------
  //  STATE OF THE DECK HEADER LABELS
  //--------------------------------------------------------------------------------------------------------------------
  AppProperty { id: headerSettingTopLeft;       path: "app.traktor.settings.deckheader.top.left";  }  
  AppProperty { id: headerSettingTopMid;        path: "app.traktor.settings.deckheader.top.mid";   }  
  AppProperty { id: headerSettingTopRight;      path: "app.traktor.settings.deckheader.top.right"; }
  AppProperty { id: headerSettingMidLeft;       path: "app.traktor.settings.deckheader.mid.left";  }  
  AppProperty { id: headerSettingMidMid;        path: "app.traktor.settings.deckheader.mid.mid";   }  
  AppProperty { id: headerSettingMidRight;      path: "app.traktor.settings.deckheader.mid.right"; }

  AppProperty { id: sequencerOn;   path: "app.traktor.decks." + (deckId + 1) + ".remix.sequencer.on" }
  readonly property bool showStepSequencer: (deckType == DeckType.Remix) && sequencerOn.value && (screen.flavor != ScreenFlavor.S5)
  onShowStepSequencerChanged: { updateLoopSize(); }

  //--------------------------------------------------------------------------------------------------------------------
  //  UPDATE VIEW
  //--------------------------------------------------------------------------------------------------------------------

  Component.onCompleted:  { updateHeader(); }
  onHeaderStateChanged:   { updateHeader(); }
  onIsLoadedChanged:      { updateHeader(); }
  onDeckTypeChanged:      { updateHeader(); }
  onSyncPhaseChanged:     { updateHeader(); }
  onIsMasterChanged:      { updateHeader(); }

  function updateHeader() {
    updateExplicitDeckHeaderNames();
    updateCoverArt();
    updateLoopSize();
    updatePhaseSyncBlinker();
  }



  //--------------------------------------------------------------------------------------------------------------------
  //  DECK HEADER TEXT
  //--------------------------------------------------------------------------------------------------------------------

  Rectangle {
    id:top_line;
    anchors.horizontalCenter: parent.horizontalCenter
    width:  deck_header.width // (headerState == "small") ? deck_header.width-18 : deck_header.width
    height: 1
    color:  textColors[deck_Id]
    Behavior on width { NumberAnimation { duration: 0.5*speed } }
  }

  // top_left_text: TITEL
  DeckHeaderText {
    id: top_left_text
    deckId: deck_Id
    explicitName: ""
    maxTextWidth : 276 // (deckType == DeckType.Stem) ? 200 - stem_text.width : 200
    textState: topLeftState
    color:     textColors[deck_Id]
    elide:     Text.ElideRight
    font.pixelSize:     fonts.scale(13)
    anchors.top:        top_line.bottom
    anchors.left:       parent.left

    anchors.topMargin:  -1
    anchors.leftMargin: 3
    Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
  }

  // top_middle_text: REMAINING TIME
  DeckHeaderText {
    id: top_middle_text
    deckId: deck_Id
    explicitName: ""
    maxTextWidth : 50
    textState:  topMiddleState
    font.family: "Pragmatica" // is monospaced
    color:      textColors[deck_Id]
    elide:      Text.ElideRight
    font.pixelSize: fonts.scale(13)
    horizontalAlignment: Text.AlignRight
    anchors.top:          top_line.bottom
    anchors.left:         parent.left
    anchors.topMargin:    1
    anchors.leftMargin:   299
    Behavior on anchors.topMargin   { NumberAnimation { duration: speed } }
    Behavior on anchors.rightMargin { NumberAnimation { duration: speed } }
  }

  // top_right_text: BPM
  DeckHeaderText {
    id: top_right_text
    deckId: deck_Id
    explicitName: ""
    maxTextWidth :  80
    textState:  topRightState
    font.family: "Pragmatica" // is monospaced
    color:      textColors[deck_Id]
    elide:      Text.ElideRight
    font.pixelSize: fonts.scale(13)
    anchors.top:          top_line.bottom
    anchors.left:         parent.left
    anchors.topMargin:    1
    anchors.leftMargin:   393
    Behavior on anchors.rightMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin   { NumberAnimation { duration: speed } }
  }

  MappingProperty { id: showBrowserOnTouch; path: "mapping.settings.show_browser_on_touch"; onValueChanged: { updateExplicitDeckHeaderNames() } }

  function updateExplicitDeckHeaderNames()
  {
    if (directThru.value) {
      top_left_text.explicitName      = "Direct Thru";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
    }
    else if (deckType == DeckType.Live) {
      top_left_text.explicitName      = "Live Input";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
    }
    else if ((deckType == DeckType.Track)  && !isLoaded) {
      top_left_text.explicitName      = "No Track Loaded";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
    }
    else if (deckType == DeckType.Stem && !isLoaded) {
      top_left_text.explicitName      = "No Stem Loaded";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
    }
    else if (deckType == DeckType.Remix && !isLoaded) {
      top_left_text.explicitName      = " ";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
    }
    else {
      // Switch off explicit naming!
      top_left_text.explicitName      = "";
      top_middle_text.explicitName    = "";
      top_right_text.explicitName     = "";
    }
  }


  //--------------------------------------------------------------------------------------------------------------------
  //  Phase Meter
  //--------------------------------------------------------------------------------------------------------------------

  Widgets.PhaseMeter {
    anchors.top: parent.top
    anchors.topMargin: 22
    anchors.left: parent.left
    anchors.leftMargin: 161 // (deck_header.width - phaseMeter.width) / 2
    opacity: (isLoaded && headerState == "large") ? 1 : 0
    deckId: deck_Id
    Behavior on opacity { NumberAnimation { duration: speed } }
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Deck Letter (A, B, C or D)
  //--------------------------------------------------------------------------------------------------------------------

  // Deck Letter Small
  Text {
    id: deck_letter_small
    width:               10
    height:              width
    anchors.top:         top_line.bottom
    anchors.right:       parent.right
    anchors.topMargin:   -1
    anchors.rightMargin: 3
    text:                deckLetters[deck_Id]
    color:               textColors[deck_Id]
    font.pixelSize:      fonts.scale(13)
    font.family:         "Pragmatica MediumTT"
    opacity:             1
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Loop Size
  //--------------------------------------------------------------------------------------------------------------------

  function updateLoopSize() {
    if (  headerState == "large" && isLoaded && (hasTrackStyleHeader(deckType) || (deckType == DeckType.Remix )) && !directThru.value ) {
      loop_size.opacity = 1.0;
      loop_size.opacity = showStepSequencer ? 0.0 : 1.0;
      stem_text.opacity = 0.6
    } else {
      loop_size.opacity = 0.0;
      stem_text.opacity = 0.0;
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Key & Lock indicator
  //--------------------------------------------------------------------------------------------------------------------

  function colorForKey(keyIndex) {
    return colors.musicalKeyColors[keyIndex]
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  WARNING MESSAGES
  //--------------------------------------------------------------------------------------------------------------------

  Rectangle {
    id: warning_box
    anchors.top:        parent.top
    anchors.topMargin:  1
    anchors.right:      deck_letter_small.left
    anchors.rightMargin: 3
    anchors.left:       parent.left
    anchors.leftMargin: 3
    height:             17
    color:              colors.colorBlack
    visible:            deckHeaderWarningActive.value
    
    Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }

    Text {
      id: top_warning_text
      color:              isError ? colors.colorRed : colors.colorOrange
      font.pixelSize:     fonts.scale(13)

      text: deckHeaderWarningShortMessage.value

      anchors.top:        parent.top
      anchors.left:       parent.left
      anchors.topMargin:  -1
      Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
      Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
    }
  }

  Timer {
    id: warningTimer
    interval: 1200
    repeat: true
    running: deckHeaderWarningActive.value
    onTriggered: {
      if (warning_box.opacity == 1) {
        warning_box.opacity = 0;
      } else {
        warning_box.opacity = 1;
      }
    }
  }



  //--------------------------------------------------------------------------------------------------------------------
  //  STATES FOR THE DIFFERENT HEADER SIZES
  //--------------------------------------------------------------------------------------------------------------------

  state: headerState

  states: [
    State {
      name: "small";
      PropertyChanges { target: deck_header;        height: smallHeaderHeight }
    },
    State {
      name: "medium";
      PropertyChanges { target: deck_header;        height: mediumHeaderHeight }
    },
    State {
      name: "large"; //when: temporaryMouseArea.released
      PropertyChanges { target: deck_header;        height: largeHeaderHeight }
    }
  ]
}
