package com.example.demoApi.repository;

import com.example.demoApi.model.Emergencia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EmergenciaRepository extends JpaRepository<Emergencia, Long> {
    // Busca todas as emergências de um usuário específico
    List<Emergencia> findByUsuarioId(Long usuarioId);
}