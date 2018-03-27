# LayoutXML

Android styled XML template engine for iOS written in Swift. (Mainly for technical study.)

<kbd>
<img src="https://user-images.githubusercontent.com/5572875/37922706-470cd148-3168-11e8-9a1a-861c8d61e6b3.png" width="250" />
</kbd>

### Try example project

```
$ pod try LayoutXML
```

## Installation

- [x] Carthage
- [x] Cocoa Pods
- [x] Swift Package Manager

## Usage

### 1. Write Android like XML

__layouts.xml__ contained sample project

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<XMLLayouts>
    <LinearLayout width="match_parent" height="match_parent" orientation="vertical" background_color="FFF" id="@+id/layouts">
        <AbsoluteLayout width="match_parent" height="0.0" margin="4.0" background_color="008000" weight="1.0">
            <UIView width="match_parent" height="24.0" margin="12.0" background_color="0F0" />
        </AbsoluteLayout>
        <LinearLayout width="match_parent" height="0.0" background_color="FFF" margin="4.0" orientation="horizontal" weight="1.0">
            <UIView width="0.0" height="match_parent" background_color="FFFF00" weight="1.0" />
            <UIView width="0.0" height="match_parent" background_color="FF7000" weight="2.0" />
            <UIView width="0.0" height="match_parent" background_color="FFA500" weight="3.0" />
        </LinearLayout>
        <RelativeLayout width="match_parent" height="0.0" margin="4.0" padding="4.0" background_color="1E90FF" id="@+id/relative_foundation" weight="1.0">
            <UIView width="8.0" margin-right="4.0" align_top="@+id/message" align_bottom="@id/message" background_color="0000CD" id="@+id/line" />
            <UILabel to_right_of="@id/line" align_parent="right" height="wrap_content" font="HelveticaNeue:14" text_color="@color/default_text_color" text="sample message\nsample message\nsample message" number_of_lines="0" id="@id/message" background_color="0000" />
        </RelativeLayout>
    </LinearLayout>
</XMLLayouts>
```

### 2. Load XML on view

```swift
override func viewDidLoad() {
  // ...
        
  view.loadLayoutXML(resource: "layouts") {
    // completion
  }
}
```

### 3. Update layouts if needed

```swift
// get id and find view
if let id: Int = LayoutXML.R.id("@id/layouts"), let layoutView: UIView = view.findViewByID(id) {
  layoutView.margin = view.safeAreaInsets
}

// update layout
view.refreshLayout()
```

(..WIP)
