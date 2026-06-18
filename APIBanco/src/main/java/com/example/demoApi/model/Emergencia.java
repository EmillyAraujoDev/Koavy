package com.example.demoApi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "emergencia")
public class Emergencia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Column(name = "alerta_id")
    private Long alertaId;

    @Column(precision = 9, scale = 6)
    private BigDecimal latitude;

    @Column(precision = 9, scale = 6)
    private BigDecimal longitude;

    @Column(length = 20)
    private String status = "PENDENTE";

    @Column(name = "data_hora", updatable = false)
    private LocalDateTime dataHora = LocalDateTime.now();

    @Column(name = "data_resolucao")
    private LocalDateTime dataResolucao;

    @Transient
    private BigDecimal batMomento;

    @Transient
    private BigDecimal satMomento;

    @Transient
    private String tipo;

    @Transient
    private String descricao;

    public Emergencia() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public Long getAlertaId() { return alertaId; }
    public void setAlertaId(Long alertaId) { this.alertaId = alertaId; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getDataHora() { return dataHora; }
    public void setDataHora(LocalDateTime dataHora) { this.dataHora = dataHora; }

    public LocalDateTime getDataResolucao() { return dataResolucao; }
    public void setDataResolucao(LocalDateTime dataResolucao) { this.dataResolucao = dataResolucao; }

    public BigDecimal getBatMomento() { return batMomento; }
    public void setBatMomento(BigDecimal batMomento) { this.batMomento = batMomento; }

    public BigDecimal getSatMomento() { return satMomento; }
    public void setSatMomento(BigDecimal satMomento) { this.satMomento = satMomento; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
}
