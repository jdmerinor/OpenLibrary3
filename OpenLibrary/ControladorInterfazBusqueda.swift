//
//  ControladorInterfazBusqueda.swift
//  OpenLibrary
//
//  Created by Juan Diego Merino on 12/5/15.
//  Copyright © 2015 Juan Diego Merino. All rights reserved.
//

import UIKit
import CoreData

class ControladorInterfazBusqueda: UIViewController {
    @IBOutlet weak var inputISBN: UITextField!
    let direccionServicio = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    var entidad : NSEntityDescription?
    var contexto : NSManagedObjectContext?
    
    @IBAction func buscarLibro(sender: AnyObject) {
        if let isbnABuscar = inputISBN.text {
            realizarConexion(isbnABuscar)
        }
    }
    
    //Función para realizar la conexión al servidor
    func realizarConexion (ISBN : String){
        let urlCompleta = direccionServicio + ISBN
        print(urlCompleta)
        let urlAConsultar = NSURL(string: urlCompleta)
        let sesionConexion = NSURLSession.sharedSession()
        
        let bloqueConsulta = {(datos : NSData?, respuesta : NSURLResponse?, error : NSError?) -> Void in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if((respuesta) != nil){
                    self.guardarResultadoDesdeJSON(datos,ISBN: ISBN)
                    
                }else{
                    //Presentar alerta
                    let alertaConectividad = UIAlertController(title: "Problemas de comunicacion con el servicio", message: "Hubo un error al consultar el servicio, posiblemente no tiene acceso a internet o el servidor de OpenLibrary está presentando fallas.", preferredStyle: .Alert)
                    alertaConectividad.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alertaConectividad, animated: true, completion: nil)
                }
            }
            
        }
        
        let dt = sesionConexion.dataTaskWithURL(urlAConsultar!, completionHandler: bloqueConsulta)
        dt.resume()
    }
    
    
    
    func guardarResultadoDesdeJSON(datos : NSData?,ISBN : String){
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let diccionarioPadre = json as! NSDictionary
            if let nodoISBN = diccionarioPadre["ISBN:"+ISBN]{
                let diccionarioISBN = nodoISBN as! NSDictionary
                
                
                //Captura título
                let tituloString = diccionarioISBN["title"] as! String
                
                
                //Captura autores
                let arregloAutores = diccionarioISBN["authors"] as! NSArray
                var autores = ""
                for esteAutor in arregloAutores{
                    let diccionarioAutor = esteAutor as! NSDictionary
                    let nombreAutor = diccionarioAutor["name"]
                    let nombreAutorString = nombreAutor as! String
                    autores += nombreAutorString + "\n"
                }
                
                var direccionPortada : String = ""
                //Captura de la imagen portada
                if let portada = diccionarioISBN["cover"]{
                    let diccionarioPortada = portada as! NSDictionary
                    if let portadaMediana = diccionarioPortada["medium"]{
                        direccionPortada = portadaMediana as! String
                    }
                }
                
                
                
                
                
                
                
                //Se realiza el guardado del nuevo libro en la memoria
                let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entidad!.name!, inManagedObjectContext: contexto!)
                newManagedObject.setValue(tituloString, forKey: "titulo")
                newManagedObject.setValue(autores, forKey: "autores")
                newManagedObject.setValue(direccionPortada, forKey: "urlPortada")
                newManagedObject.setValue(ISBN, forKey: "isbn")
                
                
                // Save the context.
                do {
                    try contexto!.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    //print("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
                
                self.navigationController!.popToRootViewControllerAnimated(true)
                
            }else if diccionarioPadre.allValues.count == 0{
                //Presentar alerta
                let alertaConectividad = UIAlertController(title: "No hay resultados", message: "No existe ningún libro con el ISBN: \(ISBN)", preferredStyle: .Alert)
                alertaConectividad.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertaConectividad, animated: true, completion: nil)
            }
            
            
            
            
            
        }catch let e{
            print("Hubo un problema al parse el JSON error: \(e)" )
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
