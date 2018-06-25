# MSCirclePad
<p>Compact iOS class which enables you to receive input from user. Controller has appearance similar to console analog sticks and disappears whenever is not in use</p>

#### How to use
<p>The class works both with Swift and Objective-C. Requires to implement a protocol.</p>

#### Objective-C

```Objective-C

@interface ViewController () <MSCirclePadDelegate>

@property (weak, nonatomic) IBOutlet MSCirclePad *pad;

@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.pad.delegate = self;
 }

- (void) joyTouchRecognitionDidStartWithSender: (MSCirclePad * _Nonnull) sender {
    // do something here
}

- (void) joyPositionDidChangedWithSender: (MSCirclePad * _Nonnull) sender {
   // do something here
}

- (void) joyTouchRecognitionDidEndWithSender: (MSCirclePad * _Nonnull) sender {
    // do something here
}

@end

```

#### Swift

```Swift

import UIKit
import MSCirclePad

class ViewController: UIViewController {

    @IBOutlet weak var pad: MSCirclePad!

    override func viewDidLoad() {
        super.viewDidLoad()
        pad.delegate = self
    }

}

extension ViewController : MSCirclePadDelegate {

    func joyTouchRecognitionDidStart(sender: MSCirclePad) {
       // do something here
    }

    func joyPositionDidChanged(sender: MSCirclePad) {
        // do something here
    }    

    func joyTouchRecognitionDidEnd(sender: MSCirclePad) {
        // do something here
    }

}

```



#### version alpha-0.1
<p align="center">
  <img src="screenshots/ver0_1.gif" width="50%" style="display:inline-block;"/>
</p>
