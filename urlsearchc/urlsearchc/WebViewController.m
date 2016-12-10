//
//  WebViewController.m
//  urlsearchc
//
//  Created by alexandra angehrn on 24/11/2016.
//  Copyright © 2016 alexandra angehrn. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *urlString = self.data; //récupération de la donnée envoyée par la vue principale (soit l'url)
    NSURL *url = [NSURL URLWithString:urlString];  // mise sous forme d'objet URL
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url]; //requête pour obtenir le contenu de la page
    [_webview loadRequest:urlRequest]; // execution de la requête dans la webview
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
