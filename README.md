# ProyectoDistribucion

Pasos para la ejecución del proyecto:

1. Desactivar los firewall de todos los dispositivos utilizados en el proyecto.

2. Adquirir los paquetes necesarios para la ejecución del proyecto, por medio de los comandos:

    `mix deps.get`
    `iex.bat --sname node@localhost -S mix`

    se debe de iniciarl un shell con un nodo en la red local para que se carguen todos los paquetes necesarios,
    luego se debe de salir de la misma.

3. ingresar a la ruta del proyecto:

    `cd ./proyectoDistribucion/dist/`

4. volver a inicial la terminal sin un hostname.

    `iex.bat -S mix`

5. ejecutar el comando para iniciar la interfaz de usuario:
    
    ```elixir
    Front.start()
    ```

6. al ejecutar el anterior comando encontrará el menu de opciones.
    
    ```elixir
    > 1. -> Add a Node
    > 2. -> Show the Local Nodes
    > 3. -> Send a Message
    > 4. -> Stop program
    ```

    * la **opcion 1** ingresará los nodos de la maquina, se debe de completar:
        - el nombre de la cookie 
        - las funciones a implementar por el API.
    * la **opcion 2** mostrará todos los nodos locales.
    * la **opcion 3** se debe ingresar el nombre del nodo local, el nodo destino y el mensaje que se desea enviar.
    * la **opcion 4** terminará el programa.

