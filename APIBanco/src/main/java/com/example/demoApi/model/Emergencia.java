package com.example.demoApi.model;

import jakarta.persistence.*;
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

    @Column(name = "bat_momento", precision = 5, scale = 2)
    private BigDecimal batMomento;

    @Column(name = "sat_momento", precision = 5, scale = 2)
    private BigDecimal satMomento;

    @Column(name = "pre_sistolica_momento")
    private Integer preSistolicaMomento; // Mapeia o SMALLINT

    @Column(name = "pre_diastolica_momento")
    private Integer preDiastolicaMomento; // Mapeia o SMALLINT

    @Column(length = 50)
    private String tipo;

    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "local_referencia", length = 150)
    private String localReferencia;

    @Column(precision = 9, scale = 6)
    private BigDecimal latitude;

    @Column(precision = 9, scale = 6)
    private BigDecimal longitude;

    @Column(name = "notificacao_enviada", columnDefinition = "TEXT")
    private String notificacaoEnviada;

    @Column(name = "data_hora", updatable = false)
    private LocalDateTime dataHora = LocalDateTime.now();

    // Construtores
    public Emergencia() {}

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public BigDecimal getBatMomento() { return batMomento; }
    public void setBatMomento(BigDecimal batMomento) { this.batMomento = batMomento; }

    public BigDecimal getSatMomento() { return satMomento; }
    public void setSatMomento(BigDecimal satMomento) { this.satMomento = satMomento; }

    public Integer getPreSistolicaMomento() { return preSistolicaMomento; }
    public void setPreSistolicaMomento(Integer preSistolicaMomento) { this.preSistolicaMomento = preSistolicaMomento; }

    public Integer getPreDiastolicaMomento() { return preDiastolicaMomento; }
    public void setPreDiastolicaMomento(Integer preDiastolicaMomento) { this.preDiastolicaMomento = preDiastolicaMomento; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getLocalReferencia() { return localReferencia; }
    public void setLocalReferencia(String localReferencia) { this.localReferencia = localReferencia; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public String getNotificacaoEnviada() { return notificacaoEnviada; }
    public void setNotificacaoEnviada(String notificacaoEnviada) { this.notificacaoEnviada = notificacaoEnviada; }

    public LocalDateTime getDataHora() { return dataHora; }
    public void setDataHora(LocalDateTime dataHora) { this.dataHora = dataHora; }
}