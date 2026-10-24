#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UILabel *connectionLabel;
@property (nonatomic, strong) UILabel *accessoryCountLabel;
@property (nonatomic, strong) UILabel *diagnosticLabel;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) NSMutableArray<NSString *> *logEntries;
@property (nonatomic, strong) EAAccessoryManager *accessoryManager;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

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

    [self appendLog:@"BlackRestore initialized."];
    [self appendLog:@"USB feasibility prototype v0.1.0."];
    [self appendLog:@"Direct iPhone restore support is not implemented."];

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
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 18;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.scrollView addSubview:self.contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:22],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-32],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor constant:20],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [self.contentStack.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor constant:-40]
    ]];

    [self buildHeader];
    [self buildConnectionCard];
    [self buildActions];
    [self buildDiagnosticsCard];
    [self buildLogCard];
    [self buildFooter];
}

- (void)buildHeader {
    UILabel *eyebrow = [self labelWithText:@"DEVICE RECOVERY RESEARCH"
                                      size:11
                                     color:[self colorWithHex:0x9A8CFF]
                                     weight:UIFontWeightBold];

    UILabel *title = [self labelWithText:@"BlackRestore"
                                    size:34
                                   color:UIColor.whiteColor
                                   weight:UIFontWeightBold];

    UILabel *subtitle = [self labelWithText:@"Portable recovery diagnostics"
                                       size:15
                                      color:[self colorWithHex:0x9AA4B8]
                                      weight:UIFontWeightRegular];

    [self.contentStack addArrangedSubview:eyebrow];
    [self.contentStack addArrangedSubview:title];
    [self.contentStack addArrangedSubview:subtitle];

    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [self colorWithHex:0x242B3B];
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

    UILabel *heading = [self labelWithText:@"CONNECTION"
                                      size:11
                                     color:[self colorWithHex:0x9AA4B8]
                                     weight:UIFontWeightBold];

    UIStackView *statusRow = [[UIStackView alloc] init];
    statusRow.axis = UILayoutConstraintAxisHorizontal;
    statusRow.alignment = UIStackViewAlignmentCenter;
    statusRow.spacing = 10;

    UIView *indicator = [[UIView alloc] init];
    indicator.backgroundColor = [self colorWithHex:0xE6B65C];
    indicator.layer.cornerRadius = 5;
    indicator.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [indicator.widthAnchor constraintEqualToConstant:10],
        [indicator.heightAnchor constraintEqualToConstant:10]
    ]];

    self.connectionLabel = [self labelWithText:@"Checking accessories..."
                                            size:17
                                           color:UIColor.whiteColor
                                           weight:UIFontWeightSemibold];

    [statusRow addArrangedSubview:indicator];
    [statusRow addArrangedSubview:self.connectionLabel];

    self.accessoryCountLabel = [self labelWithText:@"No accessory scan completed"
                                               size:13
                                              color:[self colorWithHex:0x9AA4B8]
                                              weight:UIFontWeightRegular];

    UIButton *refreshButton = [self buttonWithTitle:@"↻  Scan Accessories"
                                             action:@selector(refreshButtonTapped)];

    [stack addArrangedSubview:heading];
    [stack addArrangedSubview:statusRow];
    [stack addArrangedSubview:self.accessoryCountLabel];
    [stack addArrangedSubview:refreshButton];

    [self.contentStack addArrangedSubview:card];
}

- (void)buildActions {
    UILabel *heading = [self labelWithText:@"TOOLS"
                                      size:11
                                     color:[self colorWithHex:0x9AA4B8]
                                     weight:UIFontWeightBold];

    [self.contentStack addArrangedSubview:heading];

    [self addActionCardWithTitle:@"Recovery Diagnostics"
                         detail:@"Inspect supported connection states and review recovery guidance."
                         symbol:@"◈"
                         action:@selector(recoveryTapped)];

    [self addActionCardWithTitle:@"Firmware Research"
                         detail:@"Review firmware requirements before attempting a restoration."
                         symbol:@"↯"
                         action:@selector(firmwareTapped)];
}

- (void)addActionCardWithTitle:(NSString *)title
                        detail:(NSString *)detail
                        symbol:(NSString *)symbol
                        action:(SEL)action {

    UIView *card = [self cardView];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.clearColor;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.numberOfLines = 0;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    UILabel *symbolLabel = [self labelWithText:symbol
                                          size:24
                                         color:[self colorWithHex:0x9A8CFF]
                                         weight:UIFontWeightBold];

    UILabel *titleLabel = [self labelWithText:title
                                         size:16
                                        color:UIColor.whiteColor
                                        weight:UIFontWeightSemibold];

    UILabel *detailLabel = [self labelWithText:detail
                                          size:13
                                         color:[self colorWithHex:0x9AA4B8]
                                         weight:UIFontWeightRegular];

    detailLabel.numberOfLines = 0;

    UIStackView *textStack = [[UIStackView alloc] init];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 6;

    [textStack addArrangedSubview:titleLabel];
    [textStack addArrangedSubview:detailLabel];

    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 14;
    row.translatesAutoresizingMaskIntoConstraints = NO;

    [row addArrangedSubview:symbolLabel];
    [row addArrangedSubview:textStack];

    [button addSubview:row];
    [card addSubview:button];

    [NSLayoutConstraint activateConstraints:@[
        [button.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [button.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
        [button.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [button.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],

        [row.topAnchor constraintEqualToAnchor:button.topAnchor],
        [row.bottomAnchor constraintEqualToAnchor:button.bottomAnchor],
        [row.leadingAnchor constraintEqualToAnchor:button.leadingAnchor],
        [row.trailingAnchor constraintEqualToAnchor:button.trailingAnchor]
    ]];

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

    UILabel *heading = [self labelWithText:@"CAPABILITY STATUS"
                                      size:11
                                     color:[self colorWithHex:0x9AA4B8]
                                     weight:UIFontWeightBold];

    self.diagnosticLabel = [self labelWithText:
        @"Accessory API: Available\n"
        @"Target iPhone detection: Unverified\n"
        @"Recovery/DFU communication: Not implemented\n"
        @"Direct firmware restoration: Not implemented"
        size:13
        color:[self colorWithHex:0xC3CBD9]
        weight:UIFontWeightRegular];

    self.diagnosticLabel.numberOfLines = 0;
    self.diagnosticLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [stack addArrangedSubview:heading];
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

    UILabel *heading = [self labelWithText:@"DIAGNOSTIC LOG"
                                      size:11
                                     color:[self colorWithHex:0x9AA4B8]
                                     weight:UIFontWeightBold];

    self.logView = [[UITextView alloc] init];
    self.logView.backgroundColor = [self colorWithHex:0x080B14];
    self.logView.textColor = [self colorWithHex:0xAFC6C0];
    self.logView.font = [UIFont monospacedSystemFontOfSize:12
                                                    weight:UIFontWeightRegular];
    self.logView.editable = NO;
    self.logView.selectable = YES;
    self.logView.scrollEnabled = NO;
    self.logView.text = @"Waiting for diagnostics...";
    self.logView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
    self.logView.layer.cornerRadius = 10;
    self.logView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.logView.heightAnchor constraintGreaterThanOrEqualToConstant:130].active = YES;

    UIButton *clearButton = [self buttonWithTitle:@"Clear Logs"
                                           action:@selector(clearLogsTapped)];

    [stack addArrangedSubview:heading];
    [stack addArrangedSubview:self.logView];
    [stack addArrangedSubview:clearButton];

    [self.contentStack addArrangedSubview:card];
}

- (void)buildFooter {
    UILabel *footer = [self labelWithText:
        @"BLACKRESTORE  •  RESEARCH BUILD 0.1.0\n"
        @"No restoration operations are performed by this prototype."
        size:11
        color:[self colorWithHex:0x707B90]
        weight:UIFontWeightRegular];

    footer.textAlignment = NSTextAlignmentCenter;
    footer.numberOfLines = 0;

    [self.contentStack addArrangedSubview:footer];
}

#pragma mark - Accessory Monitoring

- (void)registerAccessoryNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(accessoryConnected:)
                   name:EAAccessoryDidConnectNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(accessoryDisconnected:)
                   name:EAAccessoryDidDisconnectNotification
                 object:nil];

    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    [self appendLog:@"Registered supported accessory notifications."];
}

- (void)refreshAccessoryStatus {
    NSArray<EAAccessory *> *accessories =
        self.accessoryManager.connectedAccessories;

    self.accessoryCountLabel.text =
        [NSString stringWithFormat:
            @"%lu supported external accessory/accessories visible to iOS",
            (unsigned long)accessories.count];

    if (accessories.count == 0) {
        self.connectionLabel.text = @"No supported accessories detected";

        [self appendLog:
            @"Scan completed: no supported External Accessory devices reported."];
    } else {
        self.connectionLabel.text = @"Accessory connection available";

        [self appendLog:
            [NSString stringWithFormat:
                @"Scan completed: %lu accessory/accessories reported.",
                (unsigned long)accessories.count]];

        for (EAAccessory *accessory in accessories) {
            NSString *name = accessory.name ?: @"Unknown";
            NSString *manufacturer = accessory.manufacturer ?: @"Unknown";
            NSString *model = accessory.modelNumber ?: @"Unknown";

            [self appendLog:
                [NSString stringWithFormat:
                    @"Accessory: %@ | Manufacturer: %@ | Model: %@",
                    name, manufacturer, model]];
        }
    }

    [self appendLog:
        @"This scan does not establish access to a connected iPhone's recovery interface."];
}

- (void)accessoryConnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:@"Accessory connection notification received."];
        [self refreshAccessoryStatus];
    });
}

- (void)accessoryDisconnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:@"Accessory disconnection notification received."];
        [self refreshAccessoryStatus];
    });
}

#pragma mark - Actions

- (void)refreshButtonTapped {
    [self appendLog:@"Manual accessory scan requested."];
    [self refreshAccessoryStatus];
}

- (void)recoveryTapped {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Recovery Diagnostics"
                         message:
        @"This prototype cannot currently detect or control an arbitrary iPhone in Recovery or DFU mode.\n\n"
        @"The next research milestone is validating a supported USB communication path."
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
                  style:UIAlertActionStyleDefault
                handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];

    [self appendLog:@"Recovery diagnostics opened; no device operations performed."];
}

- (void)firmwareTapped {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Firmware Research"
                         message:
        @"Firmware selection and restoration are not implemented yet.\n\n"
        @"A future version will need to validate device compatibility and the target's restore requirements before attempting any operation."
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
                  style:UIAlertActionStyleDefault
                handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];

    [self appendLog:@"Firmware research screen opened; no firmware installed."];
}

- (void)clearLogsTapped {
    [self.logEntries removeAllObjects];
    self.logView.text = @"";
    [self appendLog:@"Logs cleared."];
}

#pragma mark - Helpers

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
    button.titleLabel.font = [UIFont systemFontOfSize:15
                                               weight:UIFontWeightSemibold];
    button.tintColor = UIColor.whiteColor;
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

    NSString *timestamp = [self.timeFormatter stringFromDate:[NSDate date]];

    if (!timestamp) {
        timestamp = @"--:--:--";
    }

    NSString *entry = [NSString stringWithFormat:@"[%@] %@",
                       timestamp, message];

    [self.logEntries addObject:entry];

    // Keep the in-memory log bounded.
    if (self.logEntries.count > 150) {
        [self.logEntries removeObjectAtIndex:0];
    }

    if (self.isViewLoaded && self.logView) {
        self.logView.text = [self.logEntries componentsJoinedByString:@"\n"];

        [self.logView scrollRangeToVisible:
            NSMakeRange(self.logView.text.length, 0)];
    }
}

@end
