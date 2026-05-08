package com.example.demoApi.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tutor_paciente")
public class TutorPaciente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @Column(name = "nome", nullable = false)
    private String nome;

    @Column(name = "paciente_id", nullable = false)
    private Long pacienteId;

    private Boolean principal = false;

    @Column(name = "tutor_id", nullable = true)
    private Long tutorId;

    @Column(name = "data_vinculo", updatable = false)
    private LocalDateTime dataVinculo;
    public TutorPaciente() {}

    @PrePersist
    public void prePersist() {
        if (this.dataVinculo == null) {
            this.dataVinculo = LocalDateTime.now();
        }
    }

    // GETTERS E SETTERS
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public Long getPacienteId() { return pacienteId; }
    public void setPacienteId(Long pacienteId) { this.pacienteId = pacienteId; }

    public Boolean getPrincipal() { return principal; }
    public void setPrincipal(Boolean principal) { this.principal = principal; }

    public LocalDateTime getDataVinculo() { return dataVinculo; }
    public void setDataVinculo(LocalDateTime dataVinculo) { this.dataVinculo = dataVinculo; }
}