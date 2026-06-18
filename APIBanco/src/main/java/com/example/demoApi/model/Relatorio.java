package com.example.demoApi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "relatorios")
public class Relatorio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Column(length = 20)
    private String tipo;

    @Column(name = "data_inicio")
    private LocalDate dataInicio;

    @Column(name = "data_fim")
    private LocalDate dataFim;

    @Column(name = "media_bpm", precision = 5, scale = 2)
    private BigDecimal mediaBpm;

    @Column(name = "bpm_max", precision = 5, scale = 2)
    private BigDecimal bpmMax;

    @Column(name = "bpm_min", precision = 5, scale = 2)
    private BigDecimal bpmMin;

    @Column(name = "total_alertas")
    private Integer totalAlertas;

    @Column(name = "obs_ia", columnDefinition = "TEXT")
    private String obsIa;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "data_geracao", updatable = false)
    private LocalDateTime dataGeracao = LocalDateTime.now();

    public Relatorio() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public LocalDate getDataInicio() { return dataInicio; }
    public void setDataInicio(LocalDate dataInicio) { this.dataInicio = dataInicio; }

    public LocalDate getDataFim() { return dataFim; }
    public void setDataFim(LocalDate dataFim) { this.dataFim = dataFim; }

    public BigDecimal getMediaBpm() { return mediaBpm; }
    public void setMediaBpm(BigDecimal mediaBpm) { this.mediaBpm = mediaBpm; }

    public BigDecimal getBpmMax() { return bpmMax; }
    public void setBpmMax(BigDecimal bpmMax) { this.bpmMax = bpmMax; }

    public BigDecimal getBpmMin() { return bpmMin; }
    public void setBpmMin(BigDecimal bpmMin) { this.bpmMin = bpmMin; }

    public Integer getTotalAlertas() { return totalAlertas; }
    public void setTotalAlertas(Integer totalAlertas) { this.totalAlertas = totalAlertas; }

    public String getObsIa() { return obsIa; }
    public void setObsIa(String obsIa) { this.obsIa = obsIa; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public LocalDateTime getDataGeracao() { return dataGeracao; }
    public void setDataGeracao(LocalDateTime dataGeracao) { this.dataGeracao = dataGeracao; }
}
