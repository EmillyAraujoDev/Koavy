package com.example.demoApi.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "batimentos")
public class Batimento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Column(name = "dispositivo_id")
    private Long dispositivoId;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal bpm;

    @Column(precision = 5, scale = 2)
    private BigDecimal saturacao;

    @Column(name = "pressao_sistolica")
    private Integer pressaoSistolica;

    @Column(name = "pressao_diastolica")
    private Integer pressaoDiastolica;

    @Column(precision = 4, scale = 1)
    private BigDecimal temperatura;

    @Column(length = 20)
    private String classificacao = "NORMAL";

    @Column(length = 20)
    private String origem = "MANUAL";

    @Column(updatable = false)
    private LocalDateTime timestamp = LocalDateTime.now();

    // --- CONSTRUTOR ---
    public Batimento() {}

    // --- GETTERS E SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public Long getDispositivoId() { return dispositivoId; }
    public void setDispositivoId(Long dispositivoId) { this.dispositivoId = dispositivoId; }

    public BigDecimal getBpm() { return bpm; }
    public void setBpm(BigDecimal bpm) { this.bpm = bpm; }

    public BigDecimal getFrequenciaCard() { return bpm; }
    public void setFrequenciaCard(BigDecimal frequenciaCard) { this.bpm = frequenciaCard; }

    public BigDecimal getSaturacao() { return saturacao; }
    public void setSaturacao(BigDecimal saturacao) { this.saturacao = saturacao; }

    public Integer getPressaoSistolica() { return pressaoSistolica; }
    public void setPressaoSistolica(Integer pressaoSistolica) { this.pressaoSistolica = pressaoSistolica; }

    public Integer getPressaoDiastolica() { return pressaoDiastolica; }
    public void setPressaoDiastolica(Integer pressaoDiastolica) { this.pressaoDiastolica = pressaoDiastolica; }

    public BigDecimal getTemperatura() { return temperatura; }
    public void setTemperatura(BigDecimal temperatura) { this.temperatura = temperatura; }

    public String getClassificacao() { return classificacao; }
    public void setClassificacao(String classificacao) { this.classificacao = classificacao; }

    public String getOrigem() { return origem; }
    public void setOrigem(String origem) { this.origem = origem; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public LocalDateTime getDataHora() { return timestamp; }
    public void setDataHora(LocalDateTime dataHora) { this.timestamp = dataHora; }
}
