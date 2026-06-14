package arqui.grupo5.vendiaUpdater.controller;

import arqui.grupo5.dw.db.DWRepository;
import arqui.grupo5.dw.db.OperacionalRepository;
import arqui.grupo5.dw.model.VentaOperacional;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.sql.*;
import java.util.*;

@RestController
@RequestMapping("/api/dw")
@CrossOrigin(origins = "*")
public class DWWebController {

    // endpoint ViewCrossTab
    @GetMapping("/crosstab")
    public ResponseEntity<List<Map<String, Object>>> getCrossTab() {
        String dwUrl = "jdbc:mysql://localhost:3306/logimarket_dw";
        String user = "root";
        String pass = "";
        String sql = "SELECT * FROM V_CrossTab_Ventas";

        List<Map<String, Object>> resultados = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(dwUrl, user, pass);
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData md = rs.getMetaData();
            int columnas = md.getColumnCount();
            while (rs.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                for (int i = 1; i <= columnas; i++) {
                    fila.put(md.getColumnLabel(i), rs.getObject(i));
                }
                resultados.add(fila);
            }
            return ResponseEntity.ok(resultados);
        } catch (SQLException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // endpoint ETL
    @PostMapping("/etl")
    public ResponseEntity<String> ejecutarETLWeb() {
        String bdUrl = "jdbc:mysql://localhost:3306/logimarket";
        String dwUrl = "jdbc:mysql://localhost:3306/logimarket_dw";
        String user = "root";
        String pass = "";

        try (Connection bdConn = DriverManager.getConnection(bdUrl, user, pass);
             DWRepository dwRepo = new DWRepository(dwUrl, user, pass)) {

            OperacionalRepository opRepo = new OperacionalRepository(bdConn);
            List<VentaOperacional> ventasNuevas = opRepo.leerVentasEnviadas();

            if (ventasNuevas.isEmpty()) {
                return ResponseEntity.ok("Ya está actualizado.");
            }

            int filas = dwRepo.cargarDW(ventasNuevas);
            return ResponseEntity.ok("ETL terminado. Se procesaron " + filas + " registros.");

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }
}