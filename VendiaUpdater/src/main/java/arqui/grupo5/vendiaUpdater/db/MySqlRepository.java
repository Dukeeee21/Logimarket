package arqui.grupo5.vendiaUpdater.db;

import arqui.grupo5.vendiaUpdater.model.Venta;

import java.sql.*;
import java.util.List;

public class MySqlRepository implements AutoCloseable {

    private final Connection conn;

    public MySqlRepository(String url, String user, String password) throws SQLException {
        conn = DriverManager.getConnection(url, user, password);
        crearTablaSiNoExiste();
    }

    private void crearTablaSiNoExiste() throws SQLException {
        String sql = """
            CREATE TABLE IF NOT EXISTS ventas (
                id_venta     VARCHAR(20) PRIMARY KEY,
                id_vendedor  VARCHAR(20) NOT NULL,
                fecha        VARCHAR(20) NOT NULL,
                monto_total  DOUBLE      NOT NULL,
                estado       CHAR(1)     NOT NULL,
                recibido_en  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
            )
            """;
        try (Statement st = conn.createStatement()) {
            st.execute(sql);
        }
    }

    public void insertarVenta(Venta v) throws SQLException {
        // Se delega la operación al DBMS mediante el Stored Procedure
        String sql = "{CALL SP_RegistrarVenta(?, ?, ?, ?, ?)}";

        try (CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, v.getIdVenta());
            cs.setString(2, v.getIdVendedor());
            cs.setString(3, v.getFecha());
            cs.setDouble(4, v.getMontoTotal());
            cs.setString(5, String.valueOf(v.getEstado()));
            cs.executeUpdate();
        }
    }

    public void insertarBatch(List<Venta> ventas) throws SQLException {
        if (ventas.isEmpty()) return;

        // Se delega la operación por lotes al DBMS
        String sql = "{CALL SP_RegistrarVenta(?, ?, ?, ?, ?)}";

        boolean autoCommitPrevio = conn.getAutoCommit();
        conn.setAutoCommit(false);
        try (CallableStatement cs = conn.prepareCall(sql)) {
            for (Venta v : ventas) {
                cs.setString(1, v.getIdVenta());
                cs.setString(2, v.getIdVendedor());
                cs.setString(3, v.getFecha());
                cs.setDouble(4, v.getMontoTotal());
                cs.setString(5, String.valueOf(v.getEstado()));
                cs.addBatch();
            }
            cs.executeBatch();
            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(autoCommitPrevio);
        }
    }

    @Override
    public void close() throws SQLException {
        if (conn != null && !conn.isClosed()) conn.close();
    }
}