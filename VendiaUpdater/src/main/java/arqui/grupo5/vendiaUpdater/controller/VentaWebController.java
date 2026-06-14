package arqui.grupo5.vendiaUpdater.controller;

import arqui.grupo5.vendiaUpdater.model.Venta;
import arqui.grupo5.vendiaUpdater.db.MySqlRepository;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/ventas")
@CrossOrigin(origins = "*")
public class VentaWebController {

    @PostMapping("/registrar")
    public ResponseEntity<String> registrarVentaWeb(@RequestBody Venta venta) {
        String url = "jdbc:mysql://localhost:3306/logimarket";
        String user = "root";
        String password = "";

        try (MySqlRepository repository = new MySqlRepository(url, user, password)) {
            venta.setEstado('E');

            repository.insertarVenta(venta);

            return ResponseEntity.ok("Venta registrada correctamente en el DBMS remoto.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }
}