# Yimi Delivery

Yimi delivery application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# Yimi Delivery" 

## Documentación


## Legal
Componente para terminos y condiciones.
### Métodos
- **initState (void)**  
  Primera función llamada antes de que la creacion del widget, donde se llama al webservice para obtener el texto de los términos y condiciones.
- **build (Widget)**  
  Creacion del componente.

## Login
Componente para la pantalla de login.
### Métodos
- **_login (void)**  
  Función que hace la llamada al webservice, inicia loginTry en true con setState para la animación en el botón login, llama a funcón validate.
- **validate (bool)**  
  valida los campos de texto para el correo electrónici y contraseña; ej. espacios en blanco, longitud de cadena 0, y asigna el texto de error cuando una de las condiciones se cumple.
- **build (Widget)**  
  Creacion del componente.

## Payment
### Métodos
- **initState (void)**  
  Primera función llamada antes de que la creacion del widget, donde se llama al webservice para obtener el los datosdel pago semanal para la posterior manipulación.
- **build (Widget)**  
  Creacion del componente.
- **formatDate (String)**
  Retorna una cadena de fecha formateada a dd Mmm. YYYY

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  date | String | String de una fecha con formato YYYY-mm-ddd

- **formatMonth (String)**
  Retorna una cadena de mes formateada a Mmm. ej. Ene, Feb.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  month | String | String de un mes extraido de una cadena de fecha con formato YYYY-mm-ddd

## Services/bussines
### add_service
### arrived_service
### deliered_service
### incomming_service
### service_item
### services_list

## API
### Métodos
- **login (Future\<bool>)**  
  Llamada al webservice donde se filtra la respuesta y se asignan los valores de sesión con shared preferences.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  email | String | Correo electrónico del usuario
  password | String | Contraseña del usuario

- **acceptService (Future\<bool>)**  
  Llamada al webservice para aceptar un servicio cuando llega la notificación.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  tipoServicio | String | Tipo del servicio
  ciudadId | String | Id de la ciudad del servicio

- **acceptService (Future\<bool>)**  
  Llamada al webservice para aceptar un servicio cuando llega la notificación.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  tipoServicio | String | Tipo del servicio
  ciudadId | String | Id de la ciudad del servicio

- **rejectService (void)**  
  Llamada al webservice para aceptar un servicio cuando llega la notificación.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  tipoServicio | String | Tipo del servicio
  razon | String | Raz+on de rechazo del servicio seleccionada del modal de rechazo
  
- **getPaymentByWeek (Future\<List\Map>>)**  
  Llamada al webservice para obtener los pagos semanales del usuario.
  
- **getPaymentByDay (Future\<List\Map>>)**  
  Llamada al webservice para obtener los pagos del usuario según una fecha.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  date | String | Fecha en formato YYYY-mm-dd
  
- **qrError (Future\<bool>)**  
  Llamada al webservice para registrar un problema para leer el código QR del negocio.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  idBussines | String | Id del negocio
  
- **~~getColonies (Future\<List\Map>>)~~**  
  Llamada al webservice para obtener las colonias registradas.
  
- **termsAndConditions (Future\<String>)**  
  Llamada al webservice para obtener el texto de los términos y condiciones.

- **logout (void)**  
  Llamada al webservice para quitar de la lista al usuario de la lista de los repartidores activos.
  
- **iniciarServicioMandadoNegocio (void)**  
  Llamada al webservice para quitar de la lista al usuario de la lista de los repartidores activos.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  pedidos | int | Numero de pedidos que se repartirán
  
- **iniciarServicioMandadoCliente (void)**  
  Llamada al webservice para quitar de la lista al usuario de la lista de los repartidores activos.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  pedidos | int | Numero de pedidos que se repartirán
  
- **cobrarNegocio (void)**  
  Llamada al webservice para quitar de la lista al usuario de la lista de los repartidores activos.

  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  costosArray | int | Array de los costos de los pedidos del servicio en formato [1, 2, 3, n] (Para todos los arrays)
  coloniasArray | String | Array de las coordenadas de las colonias de los pedidos del servicio
  nombresColoniasArray | int | Array de los nombres de las colonias de los pedidos del servicio
  idsColoniasArray | String | Array de los ids de las colonias de los pedidos del servicio
  telefonosArray | int | Array de los teléfonos de las colonias de los pedidos del servicio
  foliosArray | int | Array de los folios de las colonias de los pedidos del servicio

- **entregaServicioNegocio (void)**  
  Llamada al webservice para entregar un pedido segun el folio y coordenadas.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  
- **entregaServicioCliente (void)**  
  Llamada al webservice para entregar un pedido segun el folio y coordenadas.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  
- **finalizarPedidoNegocio (void)**  
  Llamada al webservice para entregar el último pedido de un negocio segun el folio y coordenadas.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio
  
  - **finalizarPedidoCliente (void)**  
  Llamada al webservice para entregar el último pedido de un cliente segun el folio y coordenadas.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  folio | String | Folio del servicio

## Main
### Métodos
- **main (void)**  
  Metodo principal encargado de correr la aplicación.

- **getSesion (Future\<String>)**  
  Obtiene el nombre de usuario guardado del login desde shared preferences.

## Main/MyApp
- **build (Widget)**  
  Creacion del widget contenedor de MaterialApp.

## Main/MyHomePage
### Métodos
- **getData (void)**  
  Obtiene los datos del usuario cuando ya esta iniciada la sesión desde SharedPreferences, tambien se encarga de devolver la aplicación al estado al que se encontraba cuando se cerro por ultima vez.
  
- **openIncommingServiceBussines (void)**  
  Abre el modal cuando llega un servicio ya sea para aceptar o rechazar.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  bussinesName | String | Nombre del negocio que pidio el servicio
  bussinesAddress | String | Dirección del negocio que pidio el servicio
  reference | String | Referencia del negocio que pidio el servicio
  serviceType | String | Tipo del servicio que se requiere
  tipoServicioID | String | Id del tipo de servicio
  bussinesAddressURL | String | URL de google maps de la dirección del negocio
  bussinesId | String | Id del negocio
  expirationTime | int | Tiempo de expiracion en segundos del servicio
  dateTime | String | Fecha y hora en la que el servicio fué mandado al usuario
  ciudad | String | Id de la ciudad del servicio
  folio | String | Folio del servicio
  phone | String | Teléfono del negocio

- **openIncommingServiceCustomer (void)**  
  Abre el modal cuando llega un servicio ya sea para aceptar o rechazar.
  
  Parametro | Tipo       | Descripción |
  --------- | ---------- | --- |
  customerName | String | Nombre del cliente que pidio el servicio
  reference | String | Referencia del cliente que pidio el servicio
  serviceType | String | Tipo del servicio que se requiere
  addressURL | String | URL de google maps de la dirección
  points | List\<Map> | Lista e los puntos de destino
  expirationTime | int | Tiempo de expiracion en segundos del servicio
  dateTime | String | Fecha y hora en la que el servicio fué mandado al usuario
  monto | num | Monto que pagará el repartidor por realizar el servicio
  telefono | String | Teléfono del cliente
  folio | String | Folio del servicio
  ciudad | String | Id de la ciudad del servicio
  tipoServicio | String | Teléfono del negocio


