#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UILabel *connectionLabel;
@property (nonatomic, strong) UILabel *accessoryCountLabel;
@property (nonatomic, strong) UILabel *diagnosticLabel;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UILabel *deviceListLabel;

@property (nonatomic, strong) NSMutableArray<NSString *> *logEntries;
@property (nonatomic, strong) EAAccessoryManager *accessoryManager;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@property (nonatomic) BOOL scanInProgress;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [self colorWithHex:0x080B14];
    self.logEntries = [NSMutableArray array];

    self.accessoryManager = [EAAccessoryManager sharedAccessoryManager];

    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"HH:mm:ss";

    [self buildInterface];
    [self registerAccessoryNotifications];

    [self appendLog:@"BlackRestore Device Detection initialized."];
    [self appendLog:@"Detection engine: ExternalAccessory framework."];
    [self appendLog:@"Target-device USB detection is not yet available."];
    [self refreshAccessoryStatus];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface

- (void)buildInterface {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;

    [self.view addSubview:self.scrollView];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor
            constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.bottomAnchor
            constraintEqualToAnchor:self.view.bottomAnchor],
        [self.scrollView.leadingAnchor
            constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor
            constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 16;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.scrollView addSubview:self.contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentStack.topAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor
            constant:22],
        [self.contentStack.bottomAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor
            constant:-28],
        [self.contentStack.leadingAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor
            constant:20],
        [self.contentStack.trailingAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor
            constant:-20],
        [self.contentStack.widthAnchor
            constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor
            constant:-40]
    ]];

    [self buildHeader];
    [self buildConnectionCard];
    [self buildDeviceListCard];
    [self buildDiagnosticsCard];
    [self buildLogCard];
}

- (void)buildHeader {
    [self.contentStack addArrangedSubview:
        [self labelWithText:@"BLACKRESTORE"
                       size:12
                      color:[self colorWithHex:0x9A8CFF]
                     weight:UIFontWeightBold]];

    [self.contentStack addArrangedSubview:
        [self labelWithText:@"Device Detection"
                       size:32
                      color:UIColor.whiteColor
                     weight:UIFontWeightBold]];

    [self.contentStack addArrangedSubview:
        [self labelWithText:@"USB feasibility research"
                       size:15
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightRegular]];

    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [self colorWithHex:0x252D40];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    [divider.heightAnchor constraintEqualToConstant:1].active = YES;

    [self.contentStack addArrangedSubview:divider];
}

- (void)buildConnectionCard {
    UIView *card = [self cardView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18]
    ]];

    [stack addArrangedSubview:
        [self labelWithText:@"CONNECTION STATUS"
                       size:11
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightBold]];

    self.connectionLabel =
        [self labelWithText:@"Waiting for scan"
                       size:18
                      color:UIColor.whiteColor
                     weight:UIFontWeightSemibold];

    self.accessoryCountLabel =
        [self labelWithText:@"No scan performed"
                       size:13
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightRegular];

    [stack addArrangedSubview:self.connectionLabel];
    [stack addArrangedSubview:self.accessoryCountLabel];

    UIButton *scanButton =
        [self buttonWithTitle:@"Scan Connected Accessories"
                       action:@selector(scanButtonTapped)];

    [stack addArrangedSubview:scanButton];

    [self.contentStack addArrangedSubview:card];
}

- (void)buildDeviceListCard {
    UIView *card = [self cardView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18]
    ]];

    [stack addArrangedSubview:
        [self labelWithText:@"DETECTED ACCESSORIES"
                       size:11
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightBold]];

    self.deviceListLabel =
        [self labelWithText:@"Run a scan to inspect supported accessories."
                       size:13
                      color:[self colorWithHex:0xD0D7E5]
                     weight:UIFontWeightRegular];

    self.deviceListLabel.numberOfLines = 0;
    self.deviceListLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [stack addArrangedSubview:self.deviceListLabel];

    [self.contentStack addArrangedSubview:card];
}

- (void)buildDiagnosticsCard {
    UIView *card = [self cardView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18]
    ]];

    [stack addArrangedSubview:
        [self labelWithText:@"CAPABILITY STATUS"
                       size:11
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightBold]];

    self.diagnosticLabel =
        [self labelWithText:
            @"Accessory API: Available\n"
             "Supported accessory enumeration: Available\n"
             "Arbitrary iPhone detection: Unverified\n"
             "Recovery Mode detection: Not implemented\n"
             "DFU detection: Not implemented\n"
             "Firmware restoration: Not implemented"
                       size:13
                      color:[self colorWithHex:0xD0D7E5]
                     weight:UIFontWeightRegular];

    self.diagnosticLabel.numberOfLines = 0;

    [stack addArrangedSubview:self.diagnosticLabel];

    [self.contentStack addArrangedSubview:card];
}

- (void)buildLogCard {
    UIView *card = [self cardView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18]
    ]];

    [stack addArrangedSubview:
        [self labelWithText:@"DETECTION LOG"
                       size:11
                      color:[self colorWithHex:0x9AA4B8]
                     weight:UIFontWeightBold]];

    self.logView = [[UITextView alloc] init];
    self.logView.backgroundColor = [self colorWithHex:0x080B14];
    self.logView.textColor = [self colorWithHex:0xAFC6C0];
    self.logView.font =
        [UIFont monospacedSystemFontOfSize:12
                                    weight:UIFontWeightRegular];

    self.logView.editable = NO;
    self.logView.selectable = YES;
    self.logView.scrollEnabled = NO;
    self.logView.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
    self.logView.layer.cornerRadius = 10;
    self.logView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.logView.heightAnchor
        constraintGreaterThanOrEqualToConstant:130].active = YES;

    [stack addArrangedSubview:self.logView];

    [stack addArrangedSubview:
        [self buttonWithTitle:@"Clear Log"
                       action:@selector(clearLogTapped)]];

    [self.contentStack addArrangedSubview:card];
}

#pragma mark - Accessory Notifications

- (void)registerAccessoryNotifications {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center addObserver:self
               selector:@selector(accessoryDidConnect:)
                   name:EAAccessoryDidConnectNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(accessoryDidDisconnect:)
                   name:EAAccessoryDidDisconnectNotification
                 object:nil];

    [self.accessoryManager registerForLocalNotifications];

    [self appendLog:@"Registered External Accessory notifications."];
}

- (void)accessoryDidConnect:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:@"Supported accessory connection event received."];
        [self refreshAccessoryStatus];
    });
}

- (void)accessoryDidDisconnect:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:@"Supported accessory disconnection event received."];
        [self refreshAccessoryStatus];
    });
}

#pragma mark - Detection

- (void)scanButtonTapped {
    if (self.scanInProgress) {
        return;
    }

    self.scanInProgress = YES;
    self.connectionLabel.text = @"Scanning supported accessories...";
    self.accessoryCountLabel.text = @"Checking the iOS accessory registry";

    [self appendLog:@"--------------------------------"];
    [self appendLog:@"Starting accessory scan."];

    [self refreshAccessoryStatus];

    self.scanInProgress = NO;
}

- (void)refreshAccessoryStatus {
    NSArray<EAAccessory *> *accessories =
        self.accessoryManager.connectedAccessories;

    NSMutableArray<NSString *> *descriptions = [NSMutableArray array];

    for (NSUInteger index = 0; index < accessories.count; index++) {
        EAAccessory *accessory = accessories[index];

        NSString *name = [self safeString:accessory.name];
        NSString *manufacturer = [self safeString:accessory.manufacturer];
        NSString *model = [self safeString:accessory.modelNumber];
        NSString *firmware = [self safeString:accessory.firmwareRevision];
        NSString *hardware = [self safeString:accessory.hardwareRevision];

        NSMutableString *details = [NSMutableString string];

        [details appendFormat:@"Accessory %lu\n", (unsigned long)(index + 1)];
        [details appendFormat:@"Name: %@\n", name];
        [details appendFormat:@"Manufacturer: %@\n", manufacturer];
        [details appendFormat:@"Model: %@\n", model];
        [details appendFormat:@"Firmware: %@\n", firmware];
        [details appendFormat:@"Hardware: %@\n", hardware];
        [details appendFormat:@"Connected: %@\n",
            accessory.isConnected ? @"Yes" : @"No"];

        NSArray<NSString *> *protocols = accessory.protocolStrings;

        if (protocols.count > 0) {
            [details appendFormat:@"Protocols: %@\n",
                [protocols componentsJoinedByString:@", "]];
        } else {
            [details appendString:@"Protocols: None reported\n"];
        }

        [descriptions addObject:details];

        [self appendLog:
            [NSString stringWithFormat:
                @"Accessory found: %@ (%@)",
                name, model]];
    }

    if (accessories.count == 0) {
        self.connectionLabel.text = @"No supported accessories detected";
        self.accessoryCountLabel.text =
            @"0 accessories reported by ExternalAccessory";

        self.deviceListLabel.text =
            @"No supported external accessories were reported by iOS.\n\n"
             "This does not prove that no cable is connected. An attached "
             "iPhone, iPad, or iPod touch may not be exposed through this API.";

        [self appendLog:@"Scan result: zero supported accessories."];
    } else {
        self.connectionLabel.text = @"Supported accessories detected";

        self.accessoryCountLabel.text =
            [NSString stringWithFormat:
                @"%lu accessory/accessories",
                (unsigned long)accessories.count];

        self.deviceListLabel.text =
            [descriptions componentsJoinedByString:@"\n--------------------\n"];

        [self appendLog:
            [NSString stringWithFormat:
                @"Scan result: %lu accessory/accessories.",
                (unsigned long)accessories.count]];
    }

    [self appendLog:
        @"Target iPhone identity has not been verified by this scan."];
}

#pragma mark - Actions

- (void)clearLogTapped {
    [self.logEntries removeAllObjects];
    self.logView.text = @"";
    [self appendLog:@"Log cleared."];
}

#pragma mark - Helpers

- (NSString *)safeString:(NSString *)value {
    if (value.length == 0) {
        return @"Not reported";
    }

    return value;
}

- (UIView *)cardView {
    UIView *view = [[UIView alloc] init];

    view.backgroundColor = [self colorWithHex:0x111725];
    view.layer.cornerRadius = 16;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [self colorWithHex:0x252D40].CGColor;
    view.translatesAutoresizingMaskIntoConstraints = NO;

    return view;
}

- (UILabel *)labelWithText:(NSString *)text
                      size:(CGFloat)size
                     color:(UIColor *)color
                    weight:(UIFontWeight)weight {

    UILabel *label = [[UILabel alloc] init];

    label.text = text;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 0;

    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

    button.backgroundColor = [self colorWithHex:0x7566E8];
    button.layer.cornerRadius = 12;
    button.tintColor = UIColor.whiteColor;

    button.titleLabel.font =
        [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];

    button.contentEdgeInsets = UIEdgeInsetsMake(13, 16, 13, 16);

    [button setTitle:title forState:UIControlStateNormal];

    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIColor *)colorWithHex:(uint32_t)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

- (void)appendLog:(NSString *)message {
    if (!self.logEntries) {
        self.logEntries = [NSMutableArray array];
    }

    NSString *timestamp =
        [self.timeFormatter stringFromDate:[NSDate date]] ?: @"--:--:--";

    NSString *entry =
        [NSString stringWithFormat:@"[%@] %@", timestamp, message];

    [self.logEntries addObject:entry];

    if (self.logEntries.count > 150) {
        [self.logEntries removeObjectAtIndex:0];
    }

    if (self.isViewLoaded && self.logView) {
        self.logView.text =
            [self.logEntries componentsJoinedByString:@"\n"];
    }
}

@end
