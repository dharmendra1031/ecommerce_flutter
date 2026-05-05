import { Flex, Heading, Button, Breadcrumb, BreadcrumbItem, BreadcrumbLink } from '@chakra-ui/react';
import { Link } from 'react-router-dom';
import { FiPlus } from 'react-icons/fi';

interface PageHeaderProps {
  title: string;
  breadcrumbs?: { label: string; href?: string }[];
  actionLabel?: string;
  actionHref?: string;
  onAction?: () => void;
}

export default function PageHeader({ title, breadcrumbs, actionLabel, actionHref, onAction }: PageHeaderProps) {
  return (
    <Flex justify="space-between" align="center" mb={6}>
      <Flex direction="column" gap={1}>
        {breadcrumbs && breadcrumbs.length > 0 && (
          <Breadcrumb fontSize="sm" color="text.muted">
            {breadcrumbs.map((b, i) => (
              <BreadcrumbItem key={i} isCurrentPage={i === breadcrumbs.length - 1}>
                {b.href ? (
                  <BreadcrumbLink as={Link} to={b.href}>{b.label}</BreadcrumbLink>
                ) : (
                  <BreadcrumbLink href="#" fontWeight="semibold" color="text.default">{b.label}</BreadcrumbLink>
                )}
              </BreadcrumbItem>
            ))}
          </Breadcrumb>
        )}
        <Heading size="lg">{title}</Heading>
      </Flex>
      {actionLabel && (
        actionHref ? (
          <Button as={Link} to={actionHref} leftIcon={<FiPlus />} colorScheme="brand" size="sm">
            {actionLabel}
          </Button>
        ) : (
          <Button leftIcon={<FiPlus />} colorScheme="brand" size="sm" onClick={onAction}>
            {actionLabel}
          </Button>
        )
      )}
    </Flex>
  );
}
