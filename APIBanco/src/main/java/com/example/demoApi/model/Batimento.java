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

    @Column(name = "frequencia_card", precision = 5, scale = 2)
    private BigDecimal frequenciaCard;

    @Column(precision = 5, scale = 2)
    private BigDecimal saturacao;

    @Column(name = "pressao_sistolica")
    private Integer pressaoSistolica;

    @Column(name = "pressao_diastolica")
    private Integer pressaoDiastolica;

    @Column(name = "nivel_estresse")
    private Integer nivelEstresse;

    private Boolean movimento;

    @Column(name = "data_hora", updatable = false)
    private LocalDateTime dataHora = LocalDateTime.now();

    // --- CONSTRUTOR ---
    public Batimento() {}

    // --- GETTERS E SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public BigDecimal getFrequenciaCard() { return frequenciaCard; }
    public void setFrequenciaCard(BigDecimal frequenciaCard) { this.frequenciaCard = frequenciaCard; }

    public BigDecimal getSaturacao() { return saturacao; }
    public void setSaturacao(BigDecimal saturacao) { this.saturacao = saturacao; }

    public Integer getPressaoSistolica() { return pressaoSistolica; }
    public void setPressaoSistolica(Integer pressaoSistolica) { this.pressaoSistolica = pressaoSistolica; }

    public Integer getPressaoDiastolica() { return pressaoDiastolica; }
    public void setPressaoDiastolica(Integer pressaoDiastolica) { this.pressaoDiastolica = pressaoDiastolica; }

    public Integer getNivelEstresse() { return nivelEstresse; }
    public void setNivelEstresse(Integer nivelEstresse) { this.nivelEstresse = nivelEstresse; }

    public Boolean getMovimento() { return movimento; }
    public void setMovimento(Boolean movimento) { this.movimento = movimento; }

    public LocalDateTime getDataHora() { return dataHora; }
    public void setDataHora(LocalDateTime dataHora) { this.dataHora = dataHora; }
}