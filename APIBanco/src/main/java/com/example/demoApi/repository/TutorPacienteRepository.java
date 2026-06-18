package com.example.demoApi.repository;

import com.example.demoApi.model.TutorPaciente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TutorPacienteRepository extends JpaRepository<TutorPaciente, Long> {
    List<TutorPaciente> findByTutorId(Long tutorId);
    List<TutorPaciente> findByPacienteId(Long pacienteId);
    Optional<TutorPaciente> findByPacienteIdAndTutorId(Long pacienteId, Long tutorId);
}
