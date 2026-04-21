package com.example.demo.config;

import java.sql.Connection;
import java.util.List;

import org.apache.ibatis.executor.statement.StatementHandler;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.mapping.ParameterMode;
import org.apache.ibatis.plugin.Interceptor;
import org.apache.ibatis.plugin.Intercepts;
import org.apache.ibatis.plugin.Invocation;
import org.apache.ibatis.plugin.Plugin;
import org.apache.ibatis.plugin.Signature;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.type.TypeHandlerRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
@Intercepts({
    @Signature(type = StatementHandler.class, method = "prepare",
               args = { Connection.class, Integer.class })
})
public class SqlLoggingInterceptor implements Interceptor {

    private static final Logger log = LoggerFactory.getLogger("SQL");

    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        StatementHandler handler = (StatementHandler) invocation.getTarget();
        MetaObject meta = SystemMetaObject.forObject(handler);

        // RoutingStatementHandler 내부 delegate 접근
        MappedStatement ms = (MappedStatement) meta.getValue("delegate.mappedStatement");
        BoundSql boundSql  = handler.getBoundSql();

        String sql = formatSql(boundSql, ms.getConfiguration());

        log.info("\n  Mapper : {}\n  SQL    : {}", ms.getId(), sql);

        return invocation.proceed();
    }

    /**
     * BoundSql의 ? 플레이스홀더를 실제 파라미터 값으로 치환해 반환
     */
    private String formatSql(BoundSql boundSql, Configuration config) {
        String sql = boundSql.getSql().replaceAll("\\s+", " ").trim();

        List<ParameterMapping> mappings = boundSql.getParameterMappings();
        if (mappings == null || mappings.isEmpty()) return sql;

        Object paramObj = boundSql.getParameterObject();
        TypeHandlerRegistry registry = config.getTypeHandlerRegistry();

        StringBuilder result = new StringBuilder(sql);
        for (ParameterMapping pm : mappings) {
            if (pm.getMode() == ParameterMode.OUT) continue;

            Object value = null;
            String prop  = pm.getProperty();

            if (boundSql.hasAdditionalParameter(prop)) {
                value = boundSql.getAdditionalParameter(prop);
            } else if (paramObj == null) {
                value = null;
            } else if (registry.hasTypeHandler(paramObj.getClass())) {
                value = paramObj;
            } else {
                MetaObject metaParam = config.newMetaObject(paramObj);
                value = metaParam.hasGetter(prop) ? metaParam.getValue(prop) : null;
            }

            String token = toSqlString(value);
            int idx = result.indexOf("?");
            if (idx >= 0) result.replace(idx, idx + 1, token);
        }
        return result.toString();
    }

    private String toSqlString(Object value) {
        if (value == null)              return "NULL";
        if (value instanceof String)    return "'" + value + "'";
        if (value instanceof java.util.Date) return "'" + value + "'";
        return String.valueOf(value);
    }

    @Override
    public Object plugin(Object target) {
        return Plugin.wrap(target, this);
    }
}
