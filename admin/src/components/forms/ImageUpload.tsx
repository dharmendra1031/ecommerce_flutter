import { Box, Button, Image, Text, VStack, Icon, HStack } from '@chakra-ui/react';
import { FiUploadCloud, FiX } from 'react-icons/fi';
import { useRef, useState } from 'react';
import toast from 'react-hot-toast';
import api from '@/lib/axios';
import { getErrorMessage } from '@/lib/utils';

interface CloudinaryImage {
  public_id: string;
  url: string;
}

interface ImageUploadProps {
  images: CloudinaryImage[];
  onChange: (images: CloudinaryImage[]) => void;
  maxFiles?: number;
}

export default function ImageUpload({ images, onChange, maxFiles = 5 }: ImageUploadProps) {
  const fileRef = useRef<HTMLInputElement>(null);
  const [isUploading, setIsUploading] = useState(false);

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;
    if (images.length + files.length > maxFiles) {
      toast.error(`Maximum ${maxFiles} images allowed`);
      return;
    }

    setIsUploading(true);

    try {
      const formData = new FormData();
      for (const file of files) {
        formData.append('images', file);
      }

      const res = await api.post('/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      const newImages: CloudinaryImage[] = res.data.images;
      onChange([...images, ...newImages]);
      toast.success(`${newImages.length} image(s) uploaded`);
    } catch (err: unknown) {
      toast.error(getErrorMessage(err, 'Upload failed'));
    } finally {
      setIsUploading(false);
      if (fileRef.current) fileRef.current.value = '';
    }
  };

  const removeImage = (publicId: string) => {
    onChange(images.filter((img) => img.public_id !== publicId));
  };

  return (
    <Box>
      <Text fontSize="sm" fontWeight="medium" mb={2}>Images</Text>

      <HStack spacing={3} wrap="wrap" mb={3}>
        {images.map((img) => (
          <Box key={img.public_id} pos="relative">
            <Image src={img.url} boxSize="80px" objectFit="cover" rounded="md" border="1px" borderColor="border.default" />
            <Button
              pos="absolute" top={-2} right={-2} size="xs"
              colorScheme="red" rounded="full" p={0} minW={5} h={5}
              onClick={() => removeImage(img.public_id)}
            >
              <Icon as={FiX} boxSize={3} />
            </Button>
          </Box>
        ))}
      </HStack>

      {images.length < maxFiles && (
        <VStack
          p={4} border="2px dashed" borderColor="border.default" rounded="md"
          cursor="pointer" _hover={{ borderColor: 'brand.400', bg: 'bg.subtle' }}
          onClick={() => fileRef.current?.click()}
          spacing={1}
        >
          <Icon as={FiUploadCloud} boxSize={8} color="icon.muted" />
          <Text fontSize="sm" color="text.muted">
            {isUploading ? 'Uploading...' : 'Click to upload images'}
          </Text>
          <Text fontSize="xs" color="text.faint">PNG, JPG up to 5MB</Text>
        </VStack>
      )}

      <input
        ref={fileRef}
        type="file"
        accept="image/*"
        multiple
        hidden
        onChange={handleUpload}
      />
    </Box>
  );
}
