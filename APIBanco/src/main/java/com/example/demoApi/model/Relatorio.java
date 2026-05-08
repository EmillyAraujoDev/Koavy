package com.example.demoApi.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "relatorios", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"usuario_id", "data_ref"})
})
public class Relatorio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Column(name = "data_ref")
    private LocalDate dataRef;

    @Column(name = "media_bpm", precision = 5, scale = 2)
    private BigDecimal mediaBpm;

    @Column(name = "bpm_max", precision = 5, scale = 2)
    private BigDecimal bpmMax;

    @Column(name = "bpm_min", precision = 5, scale = 2)
    private BigDecimal bpmMin;

    @Column(name = "media_saturacao", precision = 5, scale = 2)
    private BigDecimal mediaSaturacao;

    @Column(columnDefinition = "TEXT")
    private String obs;

    @Column(name = "data_geracao", updatable = false)
    private LocalDateTime dataGeracao = LocalDateTime.now();

    // Construtores
    public Relatorio() {}

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public LocalDate getDataRef() { return dataRef; }
    public void setDataRef(LocalDate dataRef) { this.dataRef = dataRef; }

    public BigDecimal getMediaBpm() { return mediaBpm; }
    public void setMediaBpm(BigDecimal mediaBpm) { this.mediaBpm = mediaBpm; }

    public BigDecimal getBpmMax() { return bpmMax; }
    public void setBpmMax(BigDecimal bpmMax) { this.bpmMax = bpmMax; }

    public BigDecimal getBpmMin() { return bpmMin; }
    public void setBpmMin(BigDecimal bpmMin) { this.bpmMin = bpmMin; }

    public BigDecimal getMediaSaturacao() { return mediaSaturacao; }
    public void setMediaSaturacao(BigDecimal mediaSaturacao) { this.mediaSaturacao = mediaSaturacao; }

    public String getObs() { return obs; }
    public void setObs(String obs) { this.obs = obs; }

    public LocalDateTime getDataGeracao() { return dataGeracao; }
    public void setDataGeracao(LocalDateTime dataGeracao) { this.dataGeracao = dataGeracao; }
}