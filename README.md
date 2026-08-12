# Sean Angelo Crame
## INF233
## CTADMOBL Advance Mobile Programming
 
A Flutter Project that focuses on advance topics. Covering the web to mobile transactions.
 
## Lab Activity Instance 0

- Lab 1: Discussion
 Ephemeral State (Counter) vs App State(Light/Dark mode)
  - For this lab, I learned that state management in Flutter usually falls into two categories: ephemeral (local) state and app (global) state. I use the built-in "setState" method for ephemeral state, which is great when the data only matters to a single, isolated widget, like my localized counter. Whenever I call "setState", it tells Flutter to rebuild only that specific widget's UI. This is super efficient, but I found that it doesn't scale well; if I try to pass this local data down to other screens, I have to pass it through every constructor, which is called "prop drilling" and gets really messy. On the other hand, I used "Provider" to manage my app-wide global state, like my dark/light mode theme. By moving the logic into a separate model class with "ChangeNotifier" and wrapping my app in a "ChangeNotifierProvider", I can easily grab or change that shared data from anywhere in my app. When I call "notifyListeners()", it automatically rebuilds any widget listening to it, which completely solves the prop drilling issue even though it takes a little more setup code.

- Lab 2: Discussion
  - For this lab, I learned how to build an asynchronous data-driven mobile application by establishing a clean interaction between the model, service, and screen layers to render API endpoints. The process begins with the service layer "ProductService", which is responsible for HTTP network communication with the remote API endpoint. It executes requests, handles network exceptions like converting "localhost" to "10.0.2.2" for Android emulators, and receives raw JSON response bodies. Once received, the service passes this data to the model layer "ProductModel", which handles JSON deserialization via factory constructors like "Product.fromJson". The model enforces strict type safety, maps nested data structures, and provides fallback values to ensure the app never crashes due to unexpected or null JSON data. Finally, the UI layer "ProductScreen" invokes the service method and uses a "FutureBuilder" to dynamically react to data states—rendering a loading spinner while fetching, displaying retry controls on failure, or displaying an interactive grid of products when successful. Clicking a product card passes the parsed model instance to the "ProductDetailScreen" to display complete item specifications. This activity introduced the Service-Oriented Architecture and Repository Design Pattern based on the Separation of Concerns principle. By separating network operations, data models, and UI widgets into distinct layers, the application avoids monolithic code, adheres to the Single Responsibility Principle, and enables unit testing through dependency injection.


