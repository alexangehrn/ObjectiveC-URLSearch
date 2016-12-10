//
//  ViewController.m
//  urlsearchc
//
//  Created by alexandra angehrn on 23/11/2016.
//  Copyright © 2016 alexandra angehrn. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

#import <CommonCrypto/CommonDigest.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *champText2;//Outlet du champs de résultats
@property (weak, nonatomic) IBOutlet UITextField *champText1;//Outlet du champs de recherche
@property (weak, nonatomic) IBOutlet UIImageView *imgBlock;//Outlet de l'image si le résultat est une image

@end

@implementation ViewController

- (void)viewDidLoad { // Quand la vue est chargée
    [super viewDidLoad];
    
    _imgBlock.hidden = YES;// On cache la zone de résultat si image
    _champText2.hidden = YES;// On cache la zone de résultat si html

    NSString *URL = [self applicationDocumentsDirectory]; //Chemin de l'application

    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:URL error:Nil]; // Liste des files du dossier du chemin au dessus
    for (int i = 0; i < [dirs count]; i++) //pour chaque file
    {
        NSString *obj = [dirs objectAtIndex:i]; //nom du file
        NSString *sep = @"/"; //séparateur
        NSString *final = [NSString stringWithFormat:@"%@%@%@", URL, sep, obj]; //concaténation chemin + séparaséparateur +nom du file pour avoir le chemin complet du file
    
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:final error:nil]; //obtenir les infos du file
        NSDate *result = [fileAttribs objectForKey:NSFileCreationDate];// obtenir la date de création du file
        
        NSInteger DAY_IN_MS = 1000 * 60 * 60 * 24; // Calcul d'un jour en milisecondes
        NSDate *limit = [[NSDate date] dateByAddingTimeInterval:- (7 * DAY_IN_MS)]; // Définition date aujourd'hui - 7 jours

        if([limit compare:result] == NSOrderedDescending){ // comparaison de dates, si la date de limite (aujourd'hui - 7jours est antérieure à la date de création
           [[NSFileManager defaultManager] removeItemAtPath:final error:nil]; // supprimer le file du cache
        }
    }

}

- (IBAction)webviewClick:(id)sender { // au click sur le bouton webview
    WebViewController *wc =[self.storyboard instantiateViewControllerWithIdentifier:@"webviewcontroller"]; // Instanciation de la vue Webview
    NSString *val = [self.champText1 text]; // Contenu du champ de recherche
    wc.data = val; // passage du contenu du champs sur la vue suivante
    [self.navigationController pushViewController:wc animated:YES]; // Passage à la vue suivante
}

- (IBAction)onClick:(id)sender { // au click du bouton search
    _champText2.hidden = YES; // On cache la zone de résultat si html
    _imgBlock.hidden = YES;// On cache la zone de résultat si image
    
    NSString *val = [self.champText1 text]; // Contenu du champ de recherche
    bool validate = [self validateUrl:val]; //Appel à la fonction qui valide l'url
    if(validate){ // si url valide
        NSString *myKey = [self generateMD5:val];  // lance la fonction de hashage MD5 de l'url
        NSFileManager *fileManager = [NSFileManager defaultManager]; // cache
    
        NSString *URL = [self applicationDocumentsDirectory]; // Chemin jusque l'application
        NSString *sep = @"/"; //séparateur
    
        NSString *final = [NSString stringWithFormat:@"%@%@%@", URL, sep, myKey]; //oncaténation chemin + séparaséparateur +nom du file pour avoir le chemin complet du file
    
        if ([fileManager fileExistsAtPath:final]){ //cherche si le file existe dans le cache
 
            NSString * contents =[ [NSString alloc] initWithContentsOfFile:final]; // lecture du file
            NSData *data = [[NSData alloc]initWithBase64EncodedString:contents options:NSDataBase64DecodingIgnoreUnknownCharacters];//decode de str à base 64
            
            UIImage *image = [UIImage imageWithData:data ]; //créé l'image

            self.imgBlock.image = image; //change l'image

            _imgBlock.contentMode = UIViewContentModeScaleAspectFit; //garde les proportions
            
            CGRect frame = _imgBlock.frame; //récupère la frame
            frame.size.width = 280; //resize la frame
            _imgBlock.frame = frame; //change la frame
            [_imgBlock setFrame:CGRectMake(70, 300, _imgBlock.frame.size.width, _imgBlock.frame.size.height)];//positionne  et resize la frame
            

            if (image == nil) { // si le fichier ne contient pas une image
                NSString *header = @"Fichier Existant : ";  // Affiche que le file existe
                NSString * contents =[ [NSString alloc] initWithContentsOfFile:final]; // lecture du file
            
                NSString *text = [NSString stringWithFormat:@"%@%@", header, contents];  // concaténation phrase si file existe et contenu du file
                self.champText2.text = text; //ecriture du contenu dans le champ de résultats
                _champText2.hidden = NO;//affiche le champ de résultat html

            }else{
                _imgBlock.hidden = NO;// affiche l'image du résultat
            }
        
        }else{
        
            [fileManager createFileAtPath:final contents:nil attributes:nil];  // création d'un file dans le cache à l'adresse du file recherché
        
            NSURL *toload = [NSURL URLWithString:val]; //recherche de l'url
            NSURLSession *session = [NSURLSession sharedSession];  //instantciation de la connexion
            NSURLSessionDataTask *task = [session dataTaskWithURL:toload completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { //récupération du contenu de l'url
            NSString *test = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]; //mise en forme du contenu
            
            NSInteger httpStatus = [((NSHTTPURLResponse *)response) statusCode]; // récupère le code http de la réponse à l'url

            if(httpStatus == 404){//si elle n'existe pas
                NSString *title = @"Erreur";//titre de l'alerte
                NSString *message = @"L\'URL renseignée n\'existe pas ";//message de l'alerte
                NSString *actionYes = @"ok";//bouton de l'alerte
                
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert]; //initialisation de l'alerte
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:actionYes
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                                                                  }]; // action au bouton

                
                [alert addAction:firstAction]; // ajout du bouton à l'alert
                
                [self presentViewController:alert animated:YES completion:nil]; // affichage de l'alerte

                
            }else{
               

                NSString *mimeType = [response MIMEType];// récupère le mime de la réponse
                if ([mimeType rangeOfString:@"image"].location == NSNotFound) { //si ce n'est pas une image
                    [test writeToFile:final atomically:YES];  //Ecrit le résultat dans le file créé auparavant
                    
                    dispatch_async(dispatch_get_main_queue(), ^{ //sert à réécrire dans la main thread
                        NSString *header = @"Fichier Créé :";  //Affiche que le file à été créé
                        NSString *text = [NSString stringWithFormat:@"%@%@", header, test];// concaténation phrase si file a été créé et contenu du file
                        
                        self.champText2.text = text; //ecriture du contenu dans le champ de résultats
                        _champText2.hidden = NO;//affiche le résultat html

                    });
                } else {
                    NSString *dataStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//encode de base64 à str

         
                    [dataStr writeToFile:final atomically:YES];//ecrit le str dans le file
                    
                    dispatch_async(dispatch_get_main_queue(), ^{ //sert à réécrire dans la main thread

                    UIImage *image = [UIImage imageWithData:data ]; //créé l'image
                        
                    [self.imgBlock setImage:image]; //change l'image
                        
                        _imgBlock.contentMode = UIViewContentModeScaleAspectFit; //garde les proportions
                        
                        CGRect frame = _imgBlock.frame; //récupère la frame
                        frame.size.width = 280; //resize la frame
                        _imgBlock.frame = frame; //change la frame
                        [_imgBlock setFrame:CGRectMake(70, 300, _imgBlock.frame.size.width, _imgBlock.frame.size.height)];//positionne  et resize la frame
                        _imgBlock.hidden = NO; // affiche l'image
                        
                    });
                
                }

            }
        }];
        [task resume]; //lance la tache (execution de l'url)
        
    }
    }else{
        NSString *title = @"Erreur";//titre de l'alerte
        NSString *message = @"Le format de l\'URL renseignée est incorrect";//message de l'alerte
        NSString *actionYes = @"ok";//bouton de l'alerte
        
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert]; // initialise l'alerte
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:actionYes
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              }]; // créé l'action u clic du bouton
        
        
        [alert addAction:firstAction]; // associe le bouton à l'alerte
        
        [self presentViewController:alert animated:YES completion:nil]; // affiche l'alerte
    }
}

- (NSString *)applicationDocumentsDirectory { //fonction qui permet d'obtenir le chemin auquel nous avon accès
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (BOOL) validateUrl: (NSString *) candidate {// fonction qui permet de vérifier le format de l'url
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (NSString *) generateMD5:(NSString *) input //fonction qui permet de hasher en MD5
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
