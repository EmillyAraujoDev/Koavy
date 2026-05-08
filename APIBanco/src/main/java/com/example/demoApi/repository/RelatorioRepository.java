package com.example.demoApi.repository;

import com.example.demoApi.model.Relatorio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.time.LocalDate;

@Repository
public interface RelatorioRepository extends JpaRepository<Relatorio, Long> {

    // Busca todos os relatórios de um usuário
    List<Relatorio> findByUsuarioIdOrderByDataRefDesc(Long usuarioId);

    // Busca um relatório específico de um usuário em uma data (para o UNIQUE)
    Optional<Relatorio> findByUsuarioIdAndDataRef(Long usuarioId, LocalDate dataRef);
}