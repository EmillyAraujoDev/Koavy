package com.example.demoApi.repository;

import com.example.demoApi.model.Batimento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BatimentoRepository extends JpaRepository<Batimento, Long> {
    // Busca histórico de um usuário específico
    List<Batimento> findByUsuarioIdOrderByDataHoraDesc(Long usuarioId);
}