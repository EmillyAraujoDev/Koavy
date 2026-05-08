package com.example.demoApi.repository;

import com.example.demoApi.model.TutorPaciente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TutorPacienteRepository extends JpaRepository<TutorPaciente, Long> {

    // 🔥 busca por nome do tutor
    List<TutorPaciente> findByNome(String nome);

    // continua igual
    List<TutorPaciente> findByPacienteId(Long pacienteId);
}