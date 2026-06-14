package arqui.grupo5.vendiaUpdater.model;

public class Venta {
    public static final int RECORD_SIZE  = 130;
    public static final int ID_LEN       = 20;
    public static final int VENDEDOR_LEN = 20;
    public static final int FECHA_LEN    = 20;

    private String idVenta;
    private String idVendedor;
    private String fecha;
    private double montoTotal;
    private char   estado;

    public Venta() {}

    public Venta(String idVenta, String idVendedor, String fecha, double montoTotal, char estado) {
        this.idVenta    = idVenta;
        this.idVendedor = idVendedor;
        this.fecha      = fecha;
        this.montoTotal = montoTotal;
        this.estado     = estado;
    }

    public String getIdVenta()    { return idVenta; }
    public String getIdVendedor() { return idVendedor; }
    public String getFecha()      { return fecha; }
    public double getMontoTotal() { return montoTotal; }
    public char   getEstado()     { return estado; }

    public void setIdVenta(String idVenta)       { this.idVenta = idVenta; }
    public void setIdVendedor(String idVendedor) { this.idVendedor = idVendedor; }
    public void setFecha(String fecha)           { this.fecha = fecha; }
    public void setMontoTotal(double montoTotal) { this.montoTotal = montoTotal; }
    public void setEstado(char estado)           { this.estado = estado; }

    @Override
    public String toString() {
        return String.format("[%s] vendedor=%-20s fecha=%-20s monto=%.2f estado=%c",
                idVenta, idVendedor, fecha, montoTotal, estado);
    }
}