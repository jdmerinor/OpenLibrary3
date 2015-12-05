//
//  DetailViewController.swift
//  OpenLibrary
//
//  Created by Juan Diego Merino on 12/5/15.
//  Copyright © 2015 Juan Diego Merino. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imagenPortada: UIImageView!
    @IBOutlet var textoResultado: UITextView!
    

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        //Se pinta el
        if let detail = self.detailItem {
            
            let ISBN = detail.valueForKey("isbn")!.description
            let titulo = detail.valueForKey("titulo")!.description
            let autores = detail.valueForKey("autores")!.description
            let urlPortada = detail.valueForKey("urlPortada")!.description
            pintarLibro(ISBN, titulo: titulo, autores: autores, urlPortada: urlPortada)
            
        }
    }

    
    func pintarLibro(ISBN: String, titulo:String, autores: String, urlPortada :String){
        var resultadoAImprimir = ""
        
        
        //Impresión ISBN
        resultadoAImprimir += "ISBN: \(ISBN)\n"
        
        //Impresión título
        resultadoAImprimir += "Título: \(titulo)\n"
        
        //Impresión autores
        resultadoAImprimir += "Autores: \(autores)\n"
        
        //Muestra de los resultados
        if let labelResultado = textoResultado{
            labelResultado.text = resultadoAImprimir
        }
        
        if self.imagenPortada != nil {
            self.imagenPortada.image = nil
            if urlPortada != "" {
                cargarImagen(urlPortada)
            }
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func cargarImagen(urlString:String)
    {
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            
            if (error == nil && data != nil)
            {
                func display_image()
                {
                    self.imagenPortada.image = UIImage(data: data!)
                }
                
                dispatch_async(dispatch_get_main_queue(), display_image)
            }
            
        }
        
        task.resume()
    }

}

