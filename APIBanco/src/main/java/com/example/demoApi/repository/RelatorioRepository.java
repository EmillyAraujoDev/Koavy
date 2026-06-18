package com.example.demoApi.repository;

import com.example.demoApi.model.Relatorio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RelatorioRepository extends JpaRepository<Relatorio, Long> {
    List<Relatorio> findByUsuarioIdOrderByDataGeracaoDesc(Long usuarioId);
}
