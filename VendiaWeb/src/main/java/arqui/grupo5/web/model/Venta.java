package arqui.grupo5.web.model;

public class Venta {

    private String idVenta;
    private String idVendedor;
    private String fecha;
    private double montoTotal;
    private String estado;

    public Venta() {}

    public Venta(String idVenta, String idVendedor, String fecha, double montoTotal, String estado) {
        this.idVenta     = idVenta;
        this.idVendedor  = idVendedor;
        this.fecha       = fecha;
        this.montoTotal  = montoTotal;
        this.estado      = estado;
    }

    public String getIdVenta()             { return idVenta; }
    public void   setIdVenta(String v)     { this.idVenta = v; }

    public String getIdVendedor()          { return idVendedor; }
    public void   setIdVendedor(String v)  { this.idVendedor = v; }

    public String getFecha()               { return fecha; }
    public void   setFecha(String v)       { this.fecha = v; }

    public double getMontoTotal()          { return montoTotal; }
    public void   setMontoTotal(double v)  { this.montoTotal = v; }

    public String getEstado()              { return estado; }
    public void   setEstado(String v)      { this.estado = v; }
}
