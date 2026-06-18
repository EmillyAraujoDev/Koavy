package com.example.demoApi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.LocalDateTime;

@Entity
@Table(name = "tutor_paciente", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"paciente_id", "tutor_id"})
})
public class TutorPaciente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "paciente_id", nullable = false)
    private Long pacienteId;

    @Column(name = "tutor_id", nullable = false)
    private Long tutorId;

    private Boolean principal = false;

    @Column(name = "data_vinculo", updatable = false)
    private LocalDateTime dataVinculo;

    public TutorPaciente() {}

    @PrePersist
    public void prePersist() {
        if (this.dataVinculo == null) {
            this.dataVinculo = LocalDateTime.now();
        }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getPacienteId() { return pacienteId; }
    public void setPacienteId(Long pacienteId) { this.pacienteId = pacienteId; }

    public Long getTutorId() { return tutorId; }
    public void setTutorId(Long tutorId) { this.tutorId = tutorId; }

    public Boolean getPrincipal() { return principal; }
    public void setPrincipal(Boolean principal) { this.principal = principal; }

    public LocalDateTime getDataVinculo() { return dataVinculo; }
    public void setDataVinculo(LocalDateTime dataVinculo) { this.dataVinculo = dataVinculo; }
}
